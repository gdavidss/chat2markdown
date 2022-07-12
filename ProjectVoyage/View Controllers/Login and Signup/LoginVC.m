//
//  LoginVC.m
//  ProjectVoyage
//
//  Created by Gui David on 7/6/22.
//

#import "LoginVC.h"
@import Parse;

@interface LoginVC ()
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *signupBtn;

@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (IBAction)login:(id)sender {
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
        
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
        if (error != nil) {
            [self alertFailedLogin];
            NSLog(@"User log in failed: %@", error.localizedDescription);
        } else {
            NSLog(@"User logged in successfully");
            // segue to home feed
            [self performSegueWithIdentifier:@"loginSegue" sender:nil];
        }
    }];
}


- (void) alertFailedLogin {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Login failed" message:@"Please username and/or password." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* acknowledge = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {}];
    
    [alert addAction:acknowledge];
    [self presentViewController:alert animated:YES completion:nil];
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
