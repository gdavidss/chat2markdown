//
//  SettingsVC.m
//  ProjectVoyage
//
//  Created by Gui David on 7/6/22.
//

#import "SettingsVC.h"
@import Parse;

@interface SettingsVC ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;

@end

@implementation SettingsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    PFUser *currentUser = [PFUser currentUser];
    _nameLabel.text = currentUser[@"name"];
    _usernameLabel.text = currentUser[@"username"];
    _emailLabel.text = currentUser[@"email"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
