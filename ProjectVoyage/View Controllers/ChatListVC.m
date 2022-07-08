//
//  ChatListVC.m
//  ProjectVoyage
//
//  Created by Gui David on 7/6/22.
//

#import "ChatListVC.h"
#import "Chat.h"
#import "ChatCell.h"

@interface ChatListVC () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *createChatBtn;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSArray *chats;

@end

@implementation ChatListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self postChat];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self initRefreshControl];
    [self refreshHomeFeed:self.refreshControl];
}


- (void) postChat {
    [Chat postChat:@"teste description"
          withRecipientName:@"rodolfo"
          withRecipientImage:[UIImage imageNamed:@""]
          withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if (error != nil) {
                NSLog(@"Error: %@", error.localizedDescription);
            } else {
                NSLog(@"Post made successfully");
            }
    }];
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ChatCell *chatCell = [tableView dequeueReusableCellWithIdentifier:@"ChatCell"forIndexPath:indexPath];
    chatCell.chat = self.chats[indexPath.row];
    return chatCell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.chats.count;
}

@end
