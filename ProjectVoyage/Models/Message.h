//
//  Message.h
//  ProjectVoyage
//
//  Created by Gui David on 7/8/22.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Chat.h"

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

@property (nonatomic, assign) bool isSenderMyself;
@property (nonatomic, strong) NSString *identifier;

@property (nonatomic, strong) NSString *chatId;
@property (nonatomic, strong) NSString *text;

@property (nonatomic, assign) PFUser *sender;

@property (strong, nonatomic) NSDate *date;

@property (assign, nonatomic) CGFloat height;


@end

NS_ASSUME_NONNULL_END
