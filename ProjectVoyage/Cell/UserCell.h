//
//  UserCell.h
//  ProjectVoyage
//
//  Created by Gui David on 8/1/22.
//

#import <UIKit/UIKit.h>
#import "GlobalVariables.h"
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@interface UserCell : UITableViewCell

@property (nonatomic, strong) PFUser *user;

@end

NS_ASSUME_NONNULL_END
