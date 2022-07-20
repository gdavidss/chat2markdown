//
//  ChatListVC.m
//  ProjectVoyage
//
//  Created by Gui David on 7/6/22.
//

#import "ChatListVC.h"
#import "Chat.h"
#import "ChatCell.h"
#import "MessagesVC.h"

@interface ChatListVC () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UIBarButtonItem *createChatBtn;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSArray *chats;

@end

@implementation ChatListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self initRefreshControl];
    [self refreshHomeFeed:self.refreshControl];
}


- (void) initRefreshControl {
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshHomeFeed:) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}

     
- (void) refreshHomeFeed:(UIRefreshControl *)refreshControl {
    [refreshControl beginRefreshing];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Chat"];
    [query orderByDescending:@"createdAt"];
    NSArray *queryKeys = [NSArray arrayWithObjects:@"author", @"recipientName", @"chatDescription", nil];
    [query includeKeys:queryKeys];

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *chats, NSError *error) {
        if (chats != nil) {
            self.chats = chats;
            NSLog(@"Chats succesfully loaded: %@", self.chats);
            [self.tableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    [refreshControl endRefreshing];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier  isEqual: @"MessagesSegue"] ) {
        UINavigationController *navController = [segue destinationViewController];
        MessagesVC *messagesVC = navController.viewControllers[0];
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
