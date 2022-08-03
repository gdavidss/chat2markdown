//
//  ChatCreateViewController.h
//  ProjectVoyage
//
//  Created by Gui David on 7/19/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserListViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end

NS_ASSUME_NONNULL_END
