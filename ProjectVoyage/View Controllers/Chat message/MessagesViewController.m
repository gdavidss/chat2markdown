//
//  MessagesVC.m
//  Whatsapp
//
//  Created by Gui David
//  Adapted fro


// Import ParseUI to oojective-c

// Libraries
#import <AVFoundation/AVFoundation.h>
#import "NetworkManager.h"

// Global variables
#import "GlobalVariables.h"

// Cells
#import "MessageCell.h"

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

@property (nonatomic, strong) IBOutlet Inputbar *inputbar;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *markdownButton;

@property (nonatomic, strong) PFLiveQueryClient *liveQueryClient;
@property (nonatomic, strong) PFLiveQuerySubscription *subscription;

// This assumes that there's only one other recipient in each chat, should be changed if groups are allowed
@property (nonatomic, strong) PFUser *otherRecipient;

@property (nonatomic, strong) NSMutableOrderedSet *messagesInChat;

// Pagination variables
@property (nonatomic, assign) NSInteger currentPageNumber;
@property (nonatomic, assign) bool canKeepScrolling;

@property (nonatomic, assign) int MessagesPerPage;

@end

@implementation MessagesViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    if ([[NetworkManager shared] isAppOnline]) {
        NSLog(@"App's online");
        // Query messages from the internet
    } else {
        NSLog(@"App's offline");
        // Query all messages chats locally
        // Maybe do [query fromDataLocalStore]?
    }
    
    if (!_messagesInChat) {
        _messagesInChat = [NSMutableOrderedSet new];
    }
    
    _currentPageNumber = 0;
    _MessagesPerPage = 10;
    
    [self loadMessages:_currentPageNumber];
    
    // set methods
    [self setInputbar];
    [self setTableView];
    
    [self getChatRecipient];
    
    // live queries
   //[self liveQueryMessage];
   [self liveQueryChat];
  
   [self.tableView registerClass:MessageCell.class forCellReuseIdentifier:@"MessageCell"];
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
               //[strongSelf.tableView reloadData];
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
           message.text = object[@"text"];
           message.sender = object[@"sender"];
           
           dispatch_async(dispatch_get_main_queue(), ^{
               // GD Maybe only reload data at the specific IndexPath?
               [message fetch];
               [strongSelf reloadRowContainingMessage:message];
           });
       }
   }];
}

- (Message *) findMessageByObjectId:(NSString *)objectId {
    for (Message *message in _messagesInChat) {
            if ([message.objectId isEqual:objectId]) {
                return message;
        }
    }
    return nil;
}

- (void) loadMessages:(NSInteger)pageNumber {
    PFRelation *chatMessagesRelation = [_chat relationForKey:@"messages_3"];
    PFQuery *query = [chatMessagesRelation query];
    
    NSArray *queryKeys = [NSArray arrayWithObjects:TEXT, SENDER, ORDER, @"lastOrder", nil];
    [query includeKeys:queryKeys];
    
    [query orderByDescending:@"order"];
    
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
            strongSelf->_canKeepScrolling = YES;
            
            NSArray<Message *> *messages = [[reversedMessages reverseObjectEnumerator] allObjects];
            NSMutableOrderedSet *newMessages = [NSMutableOrderedSet orderedSetWithArray:messages];
            
            for (Message *message in strongSelf->_messagesInChat) {
                [newMessages addObject:message];
            }
            NSArray *descriptor = @[[[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES]];
            [newMessages sortUsingDescriptors:descriptor];
            strongSelf->_messagesInChat = newMessages;
            [strongSelf->_tableView reloadData];
        } else {
            strongSelf->_canKeepScrolling = NO;
        }
    }];
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

#pragma mark - Set Methods

-(void)setInputbar {
    self.inputbar.placeholder = @"";
    self.inputbar.delegate = self;
    self.inputbar.sendButtonText = @"Send";
    self.inputbar.sendButtonTextColor = [UIColor colorWithRed:0 green:124/255.0 blue:1 alpha:1];
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
    self.title = [NSString stringWithFormat:@"%@ & %@", chat.recipients[0].username, chat.recipients[1].username];
}

#pragma mark - Actions

- (IBAction)didPressChatList:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)didPressMarkdown:(id)sender {
    [self performSegueWithIdentifier:@"MarkdownSegue" sender:self.chat];
    return;
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
        
        // Update backend
        // Get order of the message you just deleted and decrease one from the order of each message until the end
        
        [_messagesInChat removeObject:message];
        [self addToOrdersFromIndex:indexPath.row-1 withEndIndex:_messagesInChat.count withAmount:-1];
        
        // GD Check to see if deleteInBackground also unpins it
        [message delete];
        //[self.chat saveInBackground];
        
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
        [message save];
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
    // GD see if it's really worth it to put something here
    return @"test";
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

#pragma mark - InputbarDelegate

-(void)inputbarDidPressSendButton:(Inputbar *)inputbar {
    Message *message = [Message new];
    message.text = [Util removeEndSpaceFrom:inputbar.text];
    _chat.lastOrder++;
    message.order = _chat.lastOrder;
    
    if (_chat.current_sender == MessageSenderMyself) {
        message.sender = [PFUser currentUser];
    } else {
        message.sender = _otherRecipient;
    }
    
    // Store Message in memory
    [_messagesInChat addObject:message];
    
    // Insert Message in UI
    NSInteger positionInUI = message.order > _messagesInChat.count - 1? _messagesInChat.count - 1: message.order;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:positionInUI inSection:0];
    
    [_tableView beginUpdates];
    [_tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    [_tableView endUpdates];
    [_tableView scrollToRowAtIndexPath: [NSIndexPath indexPathForRow:([_messagesInChat count] - 1) inSection:0]
                                        atScrollPosition:UITableViewScrollPositionBottom
                                        animated:YES];
    
    //[self scrollToBottomAnimated:YES];
        
    // Save everything to parse
    [message save];
    PFRelation *chatMessagesRelation = [_chat relationForKey:MESSAGES];
    [chatMessagesRelation addObject:message];
    [_chat saveInBackground];
}

- (void)inputbarDidPressChangeSenderButton:(Inputbar *)inputbar {
    NSInteger current_sender = self.chat.current_sender;
    self.chat.current_sender = (current_sender == MessageSenderMyself)? MessageSenderSomeone: MessageSenderMyself;
}

- (void)inputbarDidChangeHeight:(CGFloat)new_height {
    self.view.keyboardTriggerOffset = new_height;
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
        markdownExportVC.otherRecipientUsername = _otherRecipient.username;
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

@end
