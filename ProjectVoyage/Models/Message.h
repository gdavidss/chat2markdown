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

@property (assign, nonatomic) MessageSender sender;
@property (assign, nonatomic) MessageStatus status;
@property (strong, nonatomic) NSString *identifier;

// GD change chatID to Chat object? You'll have to change the functions that store and retrieve messages then in the Local Storage file
@property (strong, nonatomic) NSString *chatId;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSDate *date;
@property (assign, nonatomic) CGFloat height;

+(Message *)messageFromDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
