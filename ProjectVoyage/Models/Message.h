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

@interface Message : NSObject

@property (nonatomic, assign) bool isSenderMyself;
@property (nonatomic, strong) NSString *identifier;

@property (nonatomic, strong) NSString *chatId;
@property (nonatomic, strong) NSString *text;

@property (nonatomic, assign) MessageSender sender;

// GD isn't this redundant? I think order is more important than date for displaying it correctly.
@property (strong, nonatomic) NSDate *date;

// GD why do I need height here? Reconsider this being handled automatically by message cell
@property (assign, nonatomic) CGFloat height;

+(Message *)messageFromDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
