//
//  MessageCell.h
//  ProjectVoyage
//
//  Created by Gui David on 7/8/22.
//

#import <UIKit/UIKit.h>
#import "Message.h"
#import "MessagesVC.h"

NS_ASSUME_NONNULL_BEGIN

/*
This class build bubble message cells
for incoming or outgoing messages
 */

@interface MessageCell : UITableViewCell

@property (nonatomic, strong) Message *message;

@property (weak, nonatomic) id <ContainerProtocol> delegate;

// Container
@property (strong, nonatomic) UILabel *messageType;
@property (strong, nonatomic) UIButton *deleteButton;
@property (strong, nonatomic) UIButton *editButton;
@property (strong, nonatomic) UIButton *changeSenderButton;
@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) UIImageView *bubbleImage;

- (CGFloat) bubbleCellHeight;

@end
NS_ASSUME_NONNULL_END
