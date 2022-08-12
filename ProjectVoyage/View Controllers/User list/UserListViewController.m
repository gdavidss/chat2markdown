//
//  ChatCreateViewController.m
//  ProjectVoyage
//
//  Created by Gui David on 7/19/22.
//

#import "UserListViewController.h"
#import "ChatCreateViewController.h"
#import "UserCell.h"
#import "Chat.h"
#import "Util.h"

@interface UserListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *users;

@end

@implementation UserListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self queryUsers];
}

#pragma mark - TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void) queryUsers {
    PFQuery *query = [PFQuery queryWithClassName:USER_CLASS];
    
    NSArray *queryKeys = [NSArray arrayWithObjects:NAME, USERNAME, IMAGE, nil];
    [query includeKeys:queryKeys];
    
    [query whereKey:@"objectId" notEqualTo:[PFUser currentUser].objectId];
    
    // fetch data asynchronously
    __weak __typeof(self) weakSelf = self;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *found_users, NSError *error) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        strongSelf->_users = found_users;
        [strongSelf->_tableView reloadData];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _users.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"UserCell";
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.user = _users[indexPath.row];
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UINavigationController *navController = [segue destinationViewController];
    ChatCreateViewController *chatCreateVC = navController.viewControllers[0];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    //UserCell *selectedUserCell = sender;
    chatCreateVC.user = _users[indexPath.row];
}

@end
