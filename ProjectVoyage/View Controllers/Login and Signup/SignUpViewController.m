//
//  SignUpVC.m
//  ProjectVoyage
//
//  Created by Gui David on 7/6/22.
//

#import "SignUpViewController.h"
@import Parse;

@interface SignUpViewController ()
@property (nonatomic, strong) IBOutlet UIButton *submitBtn;
@property (nonatomic, strong) IBOutlet UITextField *usernameField;
@property (nonatomic, strong) IBOutlet UITextField *emailField;
@property (nonatomic, strong) IBOutlet UITextField *passwordField;
@property (nonatomic, strong) IBOutlet UITextField *repeatPasswordField;
@property (nonatomic, strong) IBOutlet UITextField *nameField;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (IBAction)submitSignUp:(id)sender {
    if (![self areThereEmptyFields] && ![self arePasswordsDifferent] && ![self isEmailInvalid]) {
        // initialize a user object
          PFUser *newUser = [PFUser user];
                   
          newUser[@"name"] = self.nameField.text;

          newUser.username = self.usernameField.text;
          newUser.email = self.emailField.text;
          newUser.password = self.passwordField.text;
          
          // call sign up function on the object
          [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
              if (error != nil) {
                  [self alertFailedSignUp];
              } else {
                  // segue to home feed
                  [self performSegueWithIdentifier:@"submitSegue" sender:nil];
              }
          }];
    }
}

- (void) alertFailedSignUp {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sign-up failed" message:@"Something went wrong when trying to create your account." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* acknowledge = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {}];
    
    [alert addAction:acknowledge];
    [self presentViewController:alert animated:YES completion:nil];
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
    if ([_passwordField.text  isEqual: @""] || [_repeatPasswordField.text isEqual: @""]
        || [_emailField.text  isEqual: @""] || [_usernameField.text isEqual: @""] || [_nameField.text isEqual: @""]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Empty fields are not allowed" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* acknowledge = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {}];
        
        [alert addAction:acknowledge];
        [self presentViewController:alert animated:YES completion:nil];
        return YES;
    }
    return NO;
}


- (BOOL)isEmailInvalid {
    NSString *email = _emailField.text;
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    if (![emailTest evaluateWithObject:email]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Email is not formatted correctly" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* acknowledge = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {}];
        
        [alert addAction:acknowledge];
        [self presentViewController:alert animated:YES completion:nil];
        return YES;
    }
    return NO;
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
