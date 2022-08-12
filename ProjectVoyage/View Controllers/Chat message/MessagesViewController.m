//
//  MessagesViewController.m
//
//  Created by Gui David

// Libraries
#import <AVFoundation/AVFoundation.h>
#import "NetworkManager.h"

// Global variables
#import "GlobalVariables.h"

// Cells
#import "MessageCell.h"

// Local storage
#import "Cache.h"

// View controllers
#import "MessagesViewController.h"
#import "EditMessageViewController.h"
#import "MarkdownExportVC.h"

// Util
#import "Util.h"

// Helpers
#import "Inputbar.h"
#import "DAKeyboardControl.h"

@import ParseLiveQuery;

@interface MessagesViewController() <InputbarDelegate, UITableViewDataSource, UITableViewDelegate, ContainerProtocol, UITableViewDragDelegate, UITableViewDropDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate>


@property (nonatomic, strong) NSMutableOrderedSet *syncQueue;

@property (nonatomic, strong) NSTimer *connectionTimer;

@property (nonatomic, strong) IBOutlet Inputbar *inputbar;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *markdownButton;

@property (nonatomic, strong) PFLiveQueryClient *liveQueryClient;
@property (nonatomic, strong) PFLiveQuerySubscription *subscription;

// This assumes that there's only one other recipient in each chat, should be changed if groups are allowed
@property (nonatomic, strong) PFUser *otherRecipient;

// Pagination variables
@property (nonatomic, assign) NSInteger currentPageNumber;
@property (nonatomic, assign) bool canKeepScrolling;
@property (nonatomic, assign) int MessagesPerPage;

@end

@implementation MessagesViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    if (!_messagesInChat) {
        _messagesInChat = [NSMutableOrderedSet new];
    }
    if (!_syncQueue) {
        _syncQueue = [NSMutableOrderedSet new];
    }
    
    // set methods
    [self setInputbar];
    [self setTableView];
    [self.tableView registerClass:MessageCell.class forCellReuseIdentifier:@"MessageCell"];

    _currentPageNumber = 0;
    _MessagesPerPage = 10;
        
    if (![[NetworkManager shared] isAppOnline]) {
        NSLog(@"App's online");
        [self loadMessages:_currentPageNumber];
    } else {
        NSLog(@"App's offline");
        [self alertOffline];
        [self loadCachedMessages];
    }
    
    [self getChatRecipient];
    
    // live queries
    if (![[NetworkManager shared] isAppOnline]) {
       [self liveQueryChat];
        // CC - liveQuery message not yet available due to conflicts
        // [self liveQueryMessage];
    }
}

- (void) loadCachedMessages {
    PFQuery *query = [PFQuery queryWithClassName:MESSAGE_CLASS];
    
    [query whereKey:@"chatId" equalTo:_chat.objectId];
    [query fromLocalDatastore];
    [query orderByAscending:@"order"];
    
    __weak __typeof(self) weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        NSArray<Message *> *cachedMessagesArr = objects;
        strongSelf->_cachedMessages = [NSMutableOrderedSet orderedSetWithArray:cachedMessagesArr];
        strongSelf->_messagesInChat = strongSelf->_cachedMessages;
        [strongSelf->_tableView reloadData];
    }];
}

-(void) syncMessages {
    PFRelation *chatMessagesRelation = [_chat relationForKey:MESSAGES];
    for (Message *message in _syncQueue) {
        _chat.lastOrder++;
        NSInteger messageOrder = _chat.lastOrder;
        message.order = messageOrder;
        [_messagesInChat addObject:message];
        
        [chatMessagesRelation addObject:message];
        [message save];
        
    }
    [_chat save];
    
    // Check and fix any discontinuity in message orders
    [self checkOrderDiscontinuities];
    
    // Clear sync queue
    _syncQueue = [NSMutableOrderedSet new];
    
    // Recache messages
    [Cache resetCacheWithMessages:_messagesInChat];
}


- (void) checkOrderDiscontinuities {
    // Message *firstMessage = _messagesInChat[0];
    // NSInteger lastOrder = firstMessage.order;
    for (int i = 1; i < _messagesInChat.count; i++) {
        Message *currentMessage = _messagesInChat[i];
        Message *previousMessage = _messagesInChat[i - 1];;

        NSInteger currOrder = currentMessage.order;
        NSInteger lastOrder = previousMessage.order;
        
        if (currOrder != lastOrder + 1) {
            [self fixDiscontinuityFromIndex:i];
            return;
        }
        lastOrder = currOrder;
    }
}

- (void) fixDiscontinuityFromIndex:(NSInteger)index {
    NSInteger remainingMessagesCount =  _messagesInChat.count - index;
    for (NSInteger i = index; i < _messagesInChat.count; i++) {
        Message *currentMessage = _messagesInChat[i];
        Message *previousMessage = _messagesInChat[i - 1];
        currentMessage.order = previousMessage.order + 1;
        [currentMessage saveInBackground];
    }
    Message *lastMessage = _messagesInChat[remainingMessagesCount - 1];
    _chat.lastOrder = lastMessage.order;
    [_chat saveInBackground];
}


-(void) checkConnection {
    NSLog(@"Checking connection");
    // Sync messages if app is online
    if ([[NetworkManager shared] isAppOnline]) {
        NSLog(@"App's back online! Loading messages...");
        [_connectionTimer invalidate];
        [self loadMessages:_currentPageNumber];
        [self syncMessages];
    } else {
        NSLog(@"App's still offline...");
    }
}

- (void) loadMessages:(NSInteger)pageNumber {
    PFRelation *chatMessagesRelation = [_chat relationForKey:MESSAGES];
    PFQuery *query = [chatMessagesRelation query];
    
    NSArray *queryKeys = [NSArray arrayWithObjects:TEXT, SENDER, ORDER, nil];
    
    [query includeKeys:queryKeys];
    [query orderByDescending:ORDER];
    
    query.limit = _MessagesPerPage;
    query.skip = _MessagesPerPage * pageNumber;
    
    
    // Fetch data asynchronously
    __weak __typeof(self) weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray *reversedMessages, NSError *error) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        if (reversedMessages == nil) {
            NSLog(@"%@", error.localizedDescription);
        } else if ([reversedMessages count] > 0) {
            NSArray<Message *> *messages = [[reversedMessages reverseObjectEnumerator] allObjects];
            [strongSelf loadPaginatedMessages:messages];
            
            // Uncache old messages and cache results
            [Cache resetCacheWithMessages:messages];
            
            // Reload tableView
            [strongSelf->_tableView reloadData];
        } else {
            strongSelf->_canKeepScrolling = NO;
        }
    }];
    // Pin chat locally
    //[PFObject pinAll:@[_chat]];
}

-(void) loadPaginatedMessages:(NSArray<Message *>*)messages {
    _canKeepScrolling = YES;
    NSMutableOrderedSet *newMessages = [NSMutableOrderedSet orderedSetWithArray:messages];
    
    for (Message *message in _messagesInChat) {
        [newMessages addObject:message];
    }
    
    NSArray *descriptor = @[[[NSSortDescriptor alloc] initWithKey:ORDER ascending:YES]];
    [newMessages sortUsingDescriptors:descriptor];
    _messagesInChat = newMessages;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    __weak __typeof(self) weakSelf = self;
    self.view.keyboardTriggerOffset = _inputbar.frame.size.height;
    
    [self.view addKeyboardPanningWithActionHandler:^(CGRect keyboardFrameInView, BOOL opening, BOOL closing) {
        /*
         Try not to call "self" inside this block (retain cycle).
         But if you do, make sure to remove DAKeyboardControl
         when you are done with the view controller by calling:
         [self.view removeKeyboardControl];
         */
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        
        if (!strongSelf) { return; }
        CGRect toolBarFrame = strongSelf->_inputbar.frame;
        toolBarFrame.origin.y = keyboardFrameInView.origin.y - toolBarFrame.size.height;
        
        CGRect tableViewFrame = strongSelf->_tableView.frame;
        tableViewFrame.size.height = strongSelf->_inputbar.frame.origin.y - 64;
        strongSelf->_tableView.frame = tableViewFrame;
        
        [strongSelf scrollToBottomAnimated:NO];
    }];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.view endEditing:YES];
    [self.view removeKeyboardControl];
}

// remove current user from _chat.recipients and return the only user left
// this method does not work for groups
- (void) getChatRecipient {
    NSMutableArray<PFUser *> *otherUsers = [_chat.recipients mutableCopy];
    for (PFUser *user in otherUsers) {
        if ([user[@"email"] isEqual:[PFUser currentUser][@"email"]]) {
            [otherUsers removeObject:user];
            _otherRecipient = otherUsers[0];
            break;
        }
    }
}

#pragma mark - Live query

// Listens if messages are added, deleted or swapped places
- (void) liveQueryChat {
    NSString *path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];

    NSString *app_id = [dict objectForKey: @"app_id"];
    NSString *client_id = [dict objectForKey: @"client_id"];

    // using live query to immediately show the change
    self.liveQueryClient = [[PFLiveQueryClient alloc] initWithServer:@"wss://chat2markdown.b4a.io" applicationId:app_id clientKey:client_id];
    
    PFQuery *chatQuery = [PFQuery queryWithClassName:CHAT_CLASS];
    self.subscription = [self.liveQueryClient subscribeToQuery:chatQuery];
   
   __unsafe_unretained typeof(self) weakSelf = self;
   [self.subscription addUpdateHandler:^(PFQuery<PFObject *> * _Nonnull query, PFObject * _Nonnull object) {
       __strong typeof (self) strongSelf = weakSelf;
       if (object) {
           dispatch_async(dispatch_get_main_queue(), ^{
               [strongSelf loadMessages:0];
           });
       }
   }];
}

- (void) reloadRowContainingMessage:(Message *)message {
    NSInteger messageIndex = [_messagesInChat indexOfObject:message];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:messageIndex inSection:0];
    NSArray *indexPaths = [[NSArray alloc]
                           initWithObjects:indexPath, nil];
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
}

// Listens if messages are edited or the sender gets changed
- (void) liveQueryMessage {
    NSString *path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];

    NSString *app_id = [dict objectForKey: @"app_id"];
    NSString *client_id = [dict objectForKey: @"client_id"];
    
    // Using live query to immediately show the change
    self.liveQueryClient = [[PFLiveQueryClient alloc] initWithServer:@"wss://chat2markdown.b4a.io" applicationId:app_id clientKey:client_id];
    PFQuery *messageQuery = [PFQuery queryWithClassName:MESSAGE_CLASS];
    self.subscription = [self.liveQueryClient subscribeToQuery:messageQuery];
   
   __unsafe_unretained typeof(self) weakSelf = self;
   [self.subscription addUpdateHandler:^(PFQuery<PFObject *> * _Nonnull query, PFObject * _Nonnull object) {
       __strong typeof (self) strongSelf = weakSelf;
       if (object){
           Message *message = [strongSelf findMessageByObjectId:object.objectId];
           message.text = object[TEXT];
           message.sender = object[SENDER];
           
           dispatch_async(dispatch_get_main_queue(), ^{
               [message fetch];
               [strongSelf reloadRowContainingMessage:message];
           });
       }
   }];
}

#pragma mark - InputbarDelegate

-(void)inputbarDidPressSendButton:(Inputbar *)inputbar {
    Message *message = [self createMessage:inputbar.text];
    
    // Store Message in memory
    [_messagesInChat addObject:message];
    
    // Insert Message in UI
    [self insertMessageInUI:message];
    
    // Store message in Parse
    PFRelation *chatMessagesRelation = [_chat relationForKey:MESSAGES];
    [chatMessagesRelation addObject:message];
    
    // Cache message and chat
    if (![[NetworkManager shared] isAppOnline]) {
        [message pinWithName:_chat.objectId];
        [message save];
        [_chat saveInBackground];
    } else {
        // Store messages in queue to be synchronized later on
        [_syncQueue addObject:message];
    }
}

- (Message *) createMessage:(NSString *)text {
    Message *message = [Message new];
    message.text = [Util removeEndSpaceFrom:text];
    
    message.order = _chat.lastOrder;
    _chat.lastOrder++;;
    
    message.chatId = _chat.objectId;

    if (_chat.currentSender == MessageSenderMyself) {
        message.sender = [PFUser currentUser];
    } else {
        message.sender = _otherRecipient;
    }
    
    return message;
}

- (void) insertMessageInUI:(Message *)message {
    NSInteger positionInUI = message.order > _messagesInChat.count - 1? _messagesInChat.count - 1: message.order;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:positionInUI inSection:0];
    
    [_tableView beginUpdates];
    [_tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    [_tableView endUpdates];
    [_tableView scrollToRowAtIndexPath: [NSIndexPath indexPathForRow:([_messagesInChat count] - 1) inSection:0]
                                        atScrollPosition:UITableViewScrollPositionBottom
                                        animated:YES];
     
    [self scrollToBottomAnimated:YES];
}

- (void)inputbarDidPressChangeSenderButton:(Inputbar *)inputbar {
    NSInteger currentSender = self.chat.currentSender;
    self.chat.currentSender = (currentSender == MessageSenderMyself)? MessageSenderSomeone: MessageSenderMyself;
}

- (void)inputbarDidChangeHeight:(CGFloat)new_height {
    self.view.keyboardTriggerOffset = new_height;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Message *message = _messagesInChat[indexPath.row];
    return message.height;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// Swipe left to delete message
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Message *message = _messagesInChat[indexPath.row];
        
        // Update orders
        [_messagesInChat removeObject:message];
        [self addToOrdersFromIndex:indexPath.row-1 withEndIndex:_messagesInChat.count withAmount:-1];
        
        // GD Check to see if deleteInBackground also unpins it
        [message deleteInBackground];
        
        NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    }
}

// Swipe right to edit message
- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView leadingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    Message *messageToEdit = _messagesInChat[indexPath.row];
    UIContextualAction *editAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"Edit" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        [self editMessage:messageToEdit];
           completionHandler(YES);
       }];
    UISwipeActionsConfiguration *swipe = [UISwipeActionsConfiguration configurationWithActions:@[editAction]];
    return swipe;
}

// Tap on message to change sender
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self changeSender:_messagesInChat[indexPath.row]];
}

// Hold message to move position
- (NSArray<UIDragItem *> *)tableView:(UITableView *)tableView itemsForBeginningDragSession:(id<UIDragSession>)session atIndexPath:(NSIndexPath *)indexPath {
    Message *messageToMove = _messagesInChat[indexPath.row];
    UIDragItem *dragItem = [[UIDragItem alloc] initWithItemProvider:[[NSItemProvider alloc] init]];
    dragItem.localObject = messageToMove;
    return @[dragItem];
}

- (void) addToOrdersFromIndex:(NSInteger)startIndex withEndIndex:(NSInteger)endIndex withAmount:(NSInteger)amount{
    NSInteger currentIndex = startIndex + 1;
    while (currentIndex < endIndex) {
        Message *message = _messagesInChat[currentIndex];
        currentIndex++;
        message.order += amount;
        if ([[NetworkManager shared] isAppOnline]) {
            [message save];
        } else {
            //message.order = _queueOrder++;
            NSString *syncQueueIdentifier = [Cache getSyncQueueIdentifierForChat:_chat];
            [message pinWithName:syncQueueIdentifier];
        }
        if (currentIndex == _messagesInChat.count - 1 && amount == -1) {
            _chat.lastOrder = message.order + 1;
        }
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    Message *messageToMove = _messagesInChat[sourceIndexPath.row];
    messageToMove.order = destinationIndexPath.row;
    
    [_messagesInChat removeObjectAtIndex:sourceIndexPath.row];
    [_messagesInChat insertObject:messageToMove atIndex:destinationIndexPath.row];
    
    __weak __typeof(self) weakSelf = self;
    [messageToMove saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (sourceIndexPath.row > destinationIndexPath.row) {
            [self addToOrdersFromIndex:destinationIndexPath.row withEndIndex:strongSelf->_messagesInChat.count withAmount:1];
        } else {
            // GD Currently having a bug with order here, just need to do more math and models
            [self addToOrdersFromIndex:sourceIndexPath.row withEndIndex:destinationIndexPath.row withAmount:-1];
        }
    }];
    [self.chat saveInBackground];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return _chat.chatTitle;
}

// GD see if it's really worth it to put something here
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGRect frame = CGRectMake(0, 0, tableView.frame.size.width, 40);
    
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor clearColor];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UILabel *label = [[UILabel alloc] init];
    label.text = [self tableView:tableView titleForHeaderInSection:section];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"Helvetica" size:20.0];
    [label sizeToFit];
    label.center = view.center;
    label.font = [UIFont fontWithName:@"Helvetica" size:13.0];
    label.backgroundColor = [UIColor colorWithRed:207/255.0 green:220/255.0 blue:252.0/255.0 alpha:1];
    label.layer.cornerRadius = 10;
    label.layer.masksToBounds = YES;
    label.autoresizingMask = UIViewAutoresizingNone;
    [view addSubview:label];
    
    return view;
}

- (void) scrollToBottomAnimated:(BOOL)animated {
    if ([_messagesInChat count] > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:([_messagesInChat count] - 1) inSection:0];
        [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger ScrollPosition = scrollView.contentOffset.y + _tableView.safeAreaInsets.top;
    if (ScrollPosition <= TRIGGER_PAGINATION_POSITION) {
        if (_canKeepScrolling) {
            _currentPageNumber++;
            [self loadMessages:_currentPageNumber];
        }
    }
}


#pragma mark - Set Methods

-(void)setInputbar {
    self.inputbar.placeholder = @"";
    self.inputbar.delegate = self;
}

-(void) setTableView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f,self.view.frame.size.width, 10.0f)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor]; // UIColorFromRGB(0xDFDBC4);

    // Drag and drop methods to move messages around
    self.tableView.dragInteractionEnabled = true;
    self.tableView.dragDelegate = self;
    self.tableView.dropDelegate = self;
    
    [self.tableView setScrollsToTop:YES];
    [self.tableView registerClass:[MessageCell class] forCellReuseIdentifier: @"MessageCell"];
}

- (void) setChat:(Chat *)chat {
    _chat = chat;
    self.title = chat.chatTitle;
}

#pragma mark - Actions

- (IBAction)didPressChatList:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)didPressMarkdown:(id)sender {
    [self performSegueWithIdentifier:@"MarkdownSegue" sender:self.chat];
    return;
}

- (Message *) findMessageByObjectId:(NSString *)objectId {
    for (Message *message in _messagesInChat) {
            if ([message.objectId isEqual:objectId]) {
                return message;
        }
    }
    return nil;
}

- (void) initializeConnectionTimer {
    _connectionTimer = [NSTimer scheduledTimerWithTimeInterval:NETWORK_CHECK_INTERVAL target:self selector:@selector(checkConnection) userInfo:nil repeats:true];
}

#pragma mark - TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_messagesInChat count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"MessageCell";
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[MessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.message = _messagesInChat[indexPath.row];
    cell.delegate = self;
    return cell;
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"EditMessageSegue"]) {
        EditMessageViewController *editMessageVC = [segue destinationViewController];
        Message *messageToPass = sender;
        editMessageVC.message = messageToPass;
        editMessageVC.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"MarkdownSegue"]) {
        MarkdownExportVC *markdownExportVC = [segue destinationViewController];
        Chat *chat = sender;
        markdownExportVC.chat = chat;
        markdownExportVC.otherRecipientUsername = _otherRecipient[NAME];
        if (![[NetworkManager shared] isAppOnline]) {
            NSMutableArray<Message *> *cachedMessages = [NSMutableArray new];
            for (Message *message in _messagesInChat) {
                [cachedMessages addObject:message];
            }
            markdownExportVC.messages = cachedMessages;
        }
    }
}

#pragma mark - Container methods

- (void)editMessage:(Message *)message {
    [self performSegueWithIdentifier:@"EditMessageSegue" sender:message];
}

- (void)changeSender:(Message *)message {
    // Gets the message cell based on the index of the array
    NSInteger messageIndex = [_messagesInChat indexOfObject:message];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:messageIndex inSection:0];
    NSArray *indexPaths = [[NSArray alloc]
                           initWithObjects:indexPath, nil];
    
    if ([message.sender.objectId isEqual:[PFUser currentUser].objectId])
        message.sender = _otherRecipient;
    else {
        message.sender = [PFUser currentUser];
    }
    
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    [message saveInBackground];
    return;
}

#pragma mark - Alerts

- (void) alertOffline {
    // Starts a timer that checks the connection periodically after user acknowledge message
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"App's offline" message:@"You will not be able to edit or change any old messages, but new messages typed will be synced once connection is back" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* acknowledge = [UIAlertAction actionWithTitle:@"I understand" style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * action) {[self initializeConnectionTimer];}];
    
    [alert addAction:acknowledge];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
