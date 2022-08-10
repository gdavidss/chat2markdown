//
//  MarkdownExportVC.h
//  ProjectVoyage
//
//  Created by Gui David on 7/15/22.
//

#import <UIKit/UIKit.h>
#import "Chat.h"

NS_ASSUME_NONNULL_BEGIN

@interface MarkdownExportVC : UIViewController

@property (strong, nonatomic) Chat *chat;
@property (nonatomic, weak) NSMutableArray<Message *> *messages;
@property (nonatomic, strong) NSString *otherRecipientUsername;

@end

NS_ASSUME_NONNULL_END
