//
//  ChatCreateViewController.m
//  ProjectVoyage
//
//  Created by Gui David on 7/19/22.
//

#import "ChatCreateViewController.h"
#import "GlobalVariables.h"
#import "UserCell.h"
#import "Chat.h"
#import "Util.h"

@interface ChatCreateViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *users;

@end

@implementation ChatCreateViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    [self queryUsers];
}

#pragma mark - TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void) queryUsers {
    PFQuery *query = [PFQuery queryWithClassName:USER_CLASS];
    
    NSArray *queryKeys = [NSArray arrayWithObjects:NAME, USERNAME, nil];
    [query includeKeys:queryKeys];
    
    [query whereKey:@"objectId" notEqualTo:[PFUser currentUser].objectId];
    
    // fetch data asynchronously
    __weak __typeof(self) weakSelf = self;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *found_users, NSError *error) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        strongSelf->_users = found_users;
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _users.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"UserCell";
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = [[UserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    if (indexPath.row == 0) {
        // generate solo chat
        cell.name = @"Myself";
    } else {
        PFUser *user = _users[indexPath.row];
        cell.name = user[NAME];
        // CC I haven't yet allowed users to upload profile pics
        // cell.userPicture = user[PICTURE]
    }
    return cell;
}


@end
