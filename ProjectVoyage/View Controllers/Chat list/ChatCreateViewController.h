//
//  ChatCreateViewController.h
//  ProjectVoyage
//
//  Created by Gui David on 7/19/22.
//

#import <UIKit/UIKit.h>
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@interface ChatCreateViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) PFUser *user;

@end

NS_ASSUME_NONNULL_END
