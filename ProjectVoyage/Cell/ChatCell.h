//
//  ChatCell.h
//  ProjectVoyage
//
//  Created by Gui David on 7/8/22.
//

#import <UIKit/UIKit.h>
#import "Chat.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChatCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *recipientLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UIImageView *recipientImage;
@property (weak, nonatomic) IBOutlet UILabel *dateChat;

@property (strong, nonatomic) Chat *chat;

@end

NS_ASSUME_NONNULL_END
