//
//  SettingsVC.m
//  ProjectVoyage
//
//  Created by Gui David on 7/6/22.
//

#import "SettingsViewController.h"
#import "LoginViewController.h"
#import "SceneDelegate.h"
@import Parse;

@interface SettingsViewController ()
@property (nonatomic, strong) IBOutlet UITextField *nameField;
@property (nonatomic, strong) IBOutlet UITextField *usernameField;
@property (nonatomic, strong) IBOutlet UITextField *emailField;
@property (nonatomic, strong) IBOutlet UITextField *passwordField;
@property (nonatomic, strong) IBOutlet UITextField *repeatPasswordField;

@end

@implementation SettingsViewController

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
            [self alertFailedDeletion];
        } else {
            // Cleans current session and return to login view controller
            [PFUser logOut];
            [self returnToLoginVC];
        }
    }];
}

- (void) alertFailedDeletion {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Account deletion failed" message:@"Something went wrong when trying to delete your account." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* acknowledge = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {}];
    
    [alert addAction:acknowledge];
    [self presentViewController:alert animated:YES completion:nil];
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
                [self displayUpdateErrorAlert];
            } else {
                [self displaySuccessAlert];
            }
        }];
    }
}

- (void) displayUpdateErrorAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Something went wront when trying to update your account. Try it later." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* acknowledge = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {}];
    
    [alert addAction:acknowledge];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) displaySuccessAlert {
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
    LoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"loginViewController"];
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
        return YES;
    }
    return NO;
}

- (BOOL) areThereEmptyFields {
    if ([_emailField.text  isEqual: @""] || [_usernameField.text isEqual: @""] || [_nameField.text isEqual: @""]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Empty fields are not allowed" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* acknowledge = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {}];
        
        [alert addAction:acknowledge];
        [self presentViewController:alert animated:YES completion:nil];
        return YES;
    }
    return NO;
}

@end
