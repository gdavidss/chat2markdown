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
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *repeatPasswordField;

@end

@implementation SettingsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    PFUser *currentUser = [PFUser currentUser];
    _nameField.text = currentUser[@"name"];
    _usernameField.text = currentUser[@"username"];
    _emailField.text = currentUser[@"email"];
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

- (IBAction)didPressUpdate:(id)sender {
    if (![self arePasswordsDifferent] && ![self areThereEmptyFields]) {
        PFUser *currentUser = [PFUser currentUser];
        currentUser[@"name"] = _nameField.text;
        currentUser[@"email"] = _emailField.text;
        currentUser[@"username"] = _usernameField.text;
        if (![_passwordField.text isEqual:@""]) {
            currentUser.password = _passwordField.text;
        }
        [currentUser saveInBackgroundWithBlock: ^(BOOL succeeded, NSError * _Nullable error) {
            if (error) {
                [self throwUpdateErrorAlert];
            } else {
                [self throwSucessAlert];
            }
        }];
    }
}


- (void) throwUpdateErrorAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Something went wront when trying to update your account. Try it later." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* acknowledge = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {}];
    
    [alert addAction:acknowledge];
    [self presentViewController:alert animated:YES completion:nil];
}


- (void) throwSucessAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sucess" message:@"Your account was updated sucessfully" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* acknowledge = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * action) {
        // Return  to chat list
        [self.tabBarController setSelectedIndex:0];
    }];
    
    [alert addAction:acknowledge];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) returnToLoginVC {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginVC *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"LoginVC"];
    SceneDelegate *mySceneDelegate = (SceneDelegate * ) UIApplication.sharedApplication.connectedScenes.allObjects.firstObject.delegate;
    mySceneDelegate.window.rootViewController = loginVC;
}


- (BOOL) arePasswordsDifferent {
    if (_passwordField.text != _repeatPasswordField.text) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Passwords do not match" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* acknowledge = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {}];
        
        [alert addAction:acknowledge];
        [self presentViewController:alert animated:YES completion:nil];
        return true;
    }
    return false;
}


- (BOOL) areThereEmptyFields {
    if ([_emailField.text  isEqual: @""] || [_usernameField.text isEqual: @""] || [_nameField.text isEqual: @""]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Empty fields are not allowed" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* acknowledge = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {}];
        
        [alert addAction:acknowledge];
        [self presentViewController:alert animated:YES completion:nil];
        return true;
    }
    return false;
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
