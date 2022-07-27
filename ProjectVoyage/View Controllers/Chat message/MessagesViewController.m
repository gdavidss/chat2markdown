//
//  MessagesVC.m
//  Whatsapp
//
//  Created by Gui David
//  Adapted from Rafael Castro
//

// Libraries
#import <AVFoundation/AVFoundation.h>

// Cells
#import "MessageCell.h"

// View controllers
#import "MessagesViewController.h"
#import "EditMessageViewController.h"
#import "MarkdownExportVC.h"

// Util
#import "Util.h"

// Gateways
#import "MessageGateway.h"

// Helpers
#import "Inputbar.h"
#import "DAKeyboardControl.h"

@interface MessagesViewController() <InputbarDelegate,
                                    UITableViewDataSource, MessageGatewayDelegate, UITableViewDelegate, ContainerProtocol, UITableViewDragDelegate, UITableViewDropDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property (nonatomic, strong) IBOutlet Inputbar *inputbar;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *markdownButton;
@property (nonatomic, strong) MessageGateway *gateway;

// This assumes that there's only one other recipient in each chat, should be changed if groups are allowed
@property (nonatomic, strong) PFUser *otherRecipient;

@end

// GD I'm testing a brown color here
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation MessagesViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    [self loadMessages];
    [self setInputbar];
    [self setTableView];
    [self setGateway];
    [self getChatRecipient];
    [self.tableView registerClass:MessageCell.class forCellReuseIdentifier:@"MessageCell"];
}

// GD Is there a way to only load this once and cache it so I don't fetch it everytime I open this?
- (void) loadMessages {
    for (Message *message in _chat.messages) {
        [message fetch];
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
        
    self.view.keyboardTriggerOffset = _inputbar.frame.size.height;
    
    __weak __typeof(self) weakSelf = self;
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
        
        [strongSelf tableViewScrollToBottomAnimated:NO];
    }];
}

-(void)viewDidDisappear:(BOOL)animated
{
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

-(void)setGateway {
    self.gateway = [MessageGateway sharedInstance];
    self.gateway.delegate = self;
    self.gateway.chat = self.chat;
    // [self.gateway loadOldMessages];
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
     
    [self.tableView registerClass:[MessageCell class] forCellReuseIdentifier: @"MessageCell"];
}

- (void) setChat:(Chat *)chat {
    _chat = chat;
    self.title = [NSString stringWithFormat:@"%@ & %@", chat.recipients[0].username, chat.recipients[1].username];;
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
    return self.chat.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"MessageCell";
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[MessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.message = self.chat.messages[indexPath.row];
    cell.delegate = self;
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Message *message = self.chat.messages[indexPath.row];
    return message.height;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// Swipe left to delete message
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
       [self.chat.messages removeObjectAtIndex:indexPath.row];
        NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    }
}

// Swipe right to edit message
- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView leadingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    Message *messageToEdit = self.chat.messages[indexPath.row];
    UIContextualAction *editAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"Edit" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        [self editMessage:messageToEdit];
           completionHandler(YES);
       }];
    UISwipeActionsConfiguration *swipe = [UISwipeActionsConfiguration configurationWithActions:@[editAction]];
    return swipe;
}

// Tap on message to change sender
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self changeSender:self.chat.messages[indexPath.row]];
}

- (NSArray<UIDragItem *> *)tableView:(UITableView *)tableView itemsForBeginningDragSession:(id<UIDragSession>)session atIndexPath:(NSIndexPath *)indexPath {
    Message *messageToMove = self.chat.messages[indexPath.row];
    UIDragItem *dragItem = [[UIDragItem alloc] initWithItemProvider:[[NSItemProvider alloc] init]];
    dragItem.localObject = messageToMove;
    return @[dragItem];
}


- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    Message *messageToMove = self.chat.messages[sourceIndexPath.row];
    [self.chat.messages removeObjectAtIndex:sourceIndexPath.row];
    [self.chat.messages insertObject:messageToMove atIndex:destinationIndexPath.row];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"test";
}

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


- (void)tableViewScrollToBottomAnimated:(BOOL)animated {
    NSInteger numberOfRows = self.chat.messages.count;
    
    // Open chat in the very last message
    if (numberOfRows) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(self.chat.messages.count - 1) inSection:0];
        
        [_tableView scrollToRowAtIndexPath:indexPath
                    atScrollPosition:UITableViewScrollPositionBottom
                    animated:animated];
    }
}


#pragma mark - InputbarDelegate

-(void)inputbarDidPressSendButton:(Inputbar *)inputbar {
    Message *message = [Message new];
    message.text = [Util removeEndSpaceFrom:inputbar.text];
    
    if (_chat.current_sender == MessageSenderSomeone) {
        message.isSenderMyself = NO;
        message.sender = [PFUser currentUser];
    } else {
        message.isSenderMyself = YES;
        message.sender = _otherRecipient;
    }
    
    //Store Message in memory
    [self.chat.messages addObject:message];
    
    //Insert Message in UI
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.chat.messages.count - 1 inSection:0];
    
    [self.tableView beginUpdates];
    
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    
    [self.tableView endUpdates];
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.chat.messages.count - 1 inSection:0]
                    atScrollPosition:UITableViewScrollPositionBottom
                    animated:YES];
    
    //Send message to server
    [message saveInBackground];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Chat"];
    [query getObjectInBackgroundWithId:_chat.objectId
                                 block:^(PFObject *chat, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        }
        NSLog(@"%@", chat);
        chat[@"messages"] = self.chat.messages;
        [chat saveInBackground];
    }];
}

- (void)inputbarDidPressChangeSenderButton:(Inputbar *)inputbar {
    NSInteger current_sender = self.chat.current_sender;
    self.chat.current_sender = (current_sender == MessageSenderMyself)? MessageSenderSomeone: MessageSenderMyself;
}

- (void)inputbarDidChangeHeight:(CGFloat)new_height {
    //Update DAKeyboardControl
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
    NSInteger messageIndex = [_chat.messages indexOfObject:message];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:messageIndex inSection:0];
    NSArray *indexPaths = [[NSArray alloc]
                           initWithObjects:indexPath, nil];
    
    // Change the data model only. (reload will cause the cell to reload)
    message.isSenderMyself = (message.isSenderMyself)? NO: YES;
    message.sender = message.sender == [PFUser currentUser]? _otherRecipient: [PFUser currentUser];
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    return;
}

@end