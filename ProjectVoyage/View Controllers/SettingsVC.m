//
//  SettingsVC.m
//  ProjectVoyage
//
//  Created by Gui David on 7/6/22.
//

#import "SettingsVC.h"
#import "LoginVC.h"
#import "SceneDelegate.h"
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


- (IBAction)logout:(id)sender {
    // PFUser.current() will now be nil
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        [self returnToLoginVC];
    }];
}


- (IBAction)didPressDeleteAccount:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Are you sure?" message:@"This action cannot be undone." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* abort = [UIAlertAction actionWithTitle:@"Abort" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {}];
    UIAlertAction* proceed = [UIAlertAction actionWithTitle:@"Proceed" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {[self deleteAccount];}];
    
    [alert addAction:abort];
    [alert addAction:proceed];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) deleteAccount {
    [[PFUser currentUser] deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Something went wrong when trying to delete your account.");
        } else {
            // Cleans current session and return to login view controller
            [PFUser logOut];
            [self returnToLoginVC];
        }
    }];
}


- (void) returnToLoginVC {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginVC *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"LoginVC"];
    SceneDelegate *mySceneDelegate = (SceneDelegate * ) UIApplication.sharedApplication.connectedScenes.allObjects.firstObject.delegate;
    mySceneDelegate.window.rootViewController = loginVC;
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
