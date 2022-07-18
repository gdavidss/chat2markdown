//
//  EditMessageVC.h
//  ProjectVoyage
//
//  Created by Gui David on 7/12/22.
//

#import <UIKit/UIKit.h>
#import "Message.h"
#import "MessagesVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface EditMessageVC : UIViewController

@property (nonatomic, strong) Message *message;
@property (nonatomic, weak) MessagesVC *delegate;

@end

NS_ASSUME_NONNULL_END
