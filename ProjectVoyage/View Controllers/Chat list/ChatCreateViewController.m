//
//  ChatCreateViewController.m
//  ProjectVoyage
//
//  Created by Gui David on 7/19/22.
//

#import "ChatCreateViewController.h"
#import "Chat.h"
#import "Util.h"

@interface ChatCreateViewController ()
@property (nonatomic, strong) IBOutlet UITextField *recipientNameTextField;
@property (nonatomic, strong) IBOutlet UITextField *chatDescriptionTextField;
@property (nonatomic, strong) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) IBOutlet UIImageView *recipientImage;

@end

@implementation ChatCreateViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    [Util roundImage:_recipientImage];
}

- (IBAction)didPressCreate:(id)sender {
    // GD view controller not being dismissed
    [self dismissViewControllerAnimated:TRUE completion:^{
        [self postChat];
    }];
}

- (IBAction)trimEndSpaces:(id)sender {
    UITextField *textField = sender;
    textField.text = [Util removeEndSpaceFrom:textField.text];
}

- (void) postChat {
    [Chat postChat:_chatDescriptionTextField.text
          withRecipientName:_recipientNameTextField.text
          withRecipientImage:_recipientImage.image
          withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if (error != nil) {
                // GD Display alert error
                NSLog(@"Error: %@",
                      error.localizedDescription);
            } else {
                NSLog(@"Post made successfully");
            }
    }];
}

- (IBAction)tapGesture:(id)sender {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;

    // The Xcode simulator does not support taking pictures, so let's first check that the camera is indeed supported on the device before trying to present it.
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else {
        NSLog(@"Camera 🚫 available so we will use photo library instead");
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }

    [self presentViewController:imagePickerVC animated:YES completion:nil];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    // Get the image captured by the UIImagePickerController
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];

    // Do something with the image
    [self.recipientImage setImage:editedImage];
    
    // Dismiss UIImagePickerController to go back to compose view controller
    [self dismissViewControllerAnimated:YES completion:nil];
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
