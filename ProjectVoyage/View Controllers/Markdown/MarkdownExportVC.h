//
//  MarkdownExportVC.h
//  ProjectVoyage
//
//  Created by Gui David on 7/15/22.
//

#import <UIKit/UIKit.h>
#import "Message.h"

NS_ASSUME_NONNULL_BEGIN

@interface MarkdownExportVC : UIViewController

@property (weak, nonatomic) NSMutableArray<Message *> *messages;

@end

NS_ASSUME_NONNULL_END
