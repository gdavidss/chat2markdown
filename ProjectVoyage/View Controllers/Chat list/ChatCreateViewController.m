//
//  ChatCreateViewController.m
//  ProjectVoyage
//
//  Created by Gui David on 7/19/22.
//

#import "ChatCreateViewController.h"
#import "GlobalVariables.h"
#import "Chat.h"
#import "Util.h"

@interface ChatCreateViewController ()
@property (nonatomic, strong) IBOutlet UITextField *chatTitleTextField;
@property (nonatomic, strong) IBOutlet UITextField *chatDescriptionTextField;
@property (nonatomic, strong) IBOutlet UIImageView *chatImage;
@property (nonatomic, assign) BOOL didChangeImage;

@end

@implementation ChatCreateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [Util roundImage:_chatImage];
    
    _didChangeImage = NO;
    
    if (_user[PROFILE_PICTURE]) {
        [_chatImage setImage:_user[PROFILE_PICTURE]];
    } else {
        [_chatImage setImage:[UIImage imageNamed:@"user.png"]];
    }
    
    _chatTitleTextField.text = [NSString stringWithFormat:@"%@ & %@", [PFUser currentUser].username, _user.username];
}

- (IBAction)trimEndSpaces:(id)sender {
    UITextField *textField = sender;
    textField.text = [Util removeEndSpaceFrom:textField.text];
}

- (IBAction)didTapCreateChat:(id)sender {
    NSArray<PFUser *> *recipients = [NSArray arrayWithObjects:[PFUser currentUser], _user, nil];
    UIImage *_Nullable chatPicture = _didChangeImage? _chatImage.image: nil;
    
    [Chat postChat:_chatTitleTextField.text
         withDescription:_chatDescriptionTextField.text
         withImage:chatPicture
         withRecipients:recipients
         withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if (error != nil) {
                [self alertFailedChat];
            } else {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
    }];
}

- (IBAction)tapGesture:(id)sender {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }

    [self presentViewController:imagePickerVC animated:YES completion:nil];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    // Get the image captured by the UIImagePickerController
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];

    // Do something with the image
    [_chatImage setImage:editedImage];
    _didChangeImage = YES;
    
    // Dismiss UIImagePickerController to go back to compose view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

/* CC - I used this method to generate a bunch of chats
- (void) generateChats {
    for (PFUser *user in _users) {
        [self postChatWithUser:user];
    }
}
 */

- (void) alertFailedChat {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Chat post failed" message:@"Something went wrong when trying to create the chat." preferredStyle:UIAlertControllerStyleAlert];
    
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
