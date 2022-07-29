//
//  Message.h
//  ProjectVoyage
//
//  Created by Gui David on 7/8/22.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@import Parse;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, MessageStatus) {
    MessageStatusSending,
    MessageStatusSent,
    MessageStatusReceived,
    MessageStatusRead,
    MessageStatusFailed
};

typedef NS_ENUM(NSInteger, MessageSender) {
    MessageSenderMyself,
    MessageSenderSomeone
};

@interface Message : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *text;
@property (nonatomic, assign) PFUser *sender;

@property (assign, nonatomic) CGFloat height;

+ (void) postMessage: (NSString * _Nullable)text withSender:(PFUser *)sender withHeight:(CGFloat)height withCompletion: (PFBooleanResultBlock  _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
