//
//  ChatListVC.m
//  ProjectVoyage
//
//  Created by Gui David on 7/6/22.
//

#import "ChatListViewController.h"
#import "Chat.h"
#import "ChatCell.h"
#import "MessagesViewController.h"
#import "LoginViewController.h"

@interface ChatListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UIBarButtonItem *createChatBtn;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSArray *chats;
@property (nonatomic, strong) NSArray<PFUser *> *users;

@end

@implementation ChatListViewController

#pragma mark - Initialization

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self initRefreshControl];
}

- (void) viewWillAppear:(BOOL)animated {
    [self queryUsers];
    // [self generateChats];
}

- (void) initRefreshControl {
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshHomeFeed:) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}

- (void) queryUsers {
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    
    NSArray *queryKeys = [NSArray arrayWithObjects:@"name", @"username", nil];
    [query includeKeys:queryKeys];
    
    [query whereKey:@"objectId" notEqualTo:[PFUser currentUser].objectId];
    
    // fetch data asynchronously
    __weak __typeof(self) weakSelf = self;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *found_users, NSError *error) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        strongSelf->_users = found_users;
        [strongSelf refreshHomeFeed:strongSelf.refreshControl];
    }];
}

- (void) refreshHomeFeed:(UIRefreshControl *)refreshControl {
    [refreshControl beginRefreshing];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Chat"];
    [query orderByDescending:@"createdAt"];
    NSArray *queryKeys = [NSArray arrayWithObjects:@"recipients", @"chatDescription", nil];
    [query includeKeys:queryKeys];
    
    [query whereKey:@"recipients" containsAllObjectsInArray:@[[PFUser currentUser]]];
        // fetch data asynchronously
        __weak __typeof(self) weakSelf = self;
        [query findObjectsInBackgroundWithBlock:^(NSArray *chats, NSError *error) {
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            [refreshControl endRefreshing];
            if (!strongSelf) return;
            // GD Do I need to give an error if it's nil? what if it's just empty?
            if (chats != nil) {
                strongSelf->_chats = chats;
                [strongSelf->_tableView reloadData];
            } else {
                // GD Show alert error
                NSLog(@"%@", error.localizedDescription);
            }
        }];
}

- (void) generateChats {
    for (PFUser *user in _users) {
        [self postChatWithUser:user];
    }
}

- (void) postChatWithUser:(PFUser *)user {
    NSArray<PFUser *> *recipients = [NSArray arrayWithObjects:[PFUser currentUser], user, nil];
    [Chat postChat:@"This should be editable"
          withImage:nil
          withRecipients:recipients
          withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if (error != nil) {
                // GD Display alert error
                NSLog(@"Error: %@",
                      error.localizedDescription);
            } else {
                NSLog(@"Post made successfully");
            }
    }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier  isEqual: @"MessagesSegue"] ) {
        UINavigationController *navController = [segue destinationViewController];
        MessagesViewController *messagesVC = navController.viewControllers[0];
        ChatCell *selectedChatCell = sender;
    messagesVC.chat = selectedChatCell.chat;
    }
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ChatCell *chatCell = [tableView dequeueReusableCellWithIdentifier:@"ChatCell" forIndexPath:indexPath];
    chatCell.chat = self.chats[indexPath.row];
    return chatCell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.chats.count;
}

@end