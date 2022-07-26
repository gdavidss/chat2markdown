//
//  MessageCell.h
//  ProjectVoyage
//
//  Created by Gui David on 7/8/22.
//

#import <UIKit/UIKit.h>
#import "Message.h"
#import "MessagesViewController.h"

NS_ASSUME_NONNULL_BEGIN

/*
This class build bubble message cells
for incoming or outgoing messages
 */

@interface MessageCell : UITableViewCell

@property (nonatomic, strong) Message *message;
@property (nonatomic, weak) id <ContainerProtocol> delegate;

@end
NS_ASSUME_NONNULL_END
