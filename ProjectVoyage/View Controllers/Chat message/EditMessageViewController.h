//
//  EditMessageVC.h
//  ProjectVoyage
//
//  Created by Gui David on 7/12/22.
//

#import <UIKit/UIKit.h>
#import "Message.h"
#import "MessagesViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface EditMessageViewController : UIViewController

@property (nonatomic, strong) Message *message;
@property (nonatomic, weak) MessagesViewController *delegate;

@end

NS_ASSUME_NONNULL_END
