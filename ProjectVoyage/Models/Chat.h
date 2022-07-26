//
//  Chat.h
//  ProjectVoyage
//
//  Created by Gui David on 7/6/22.
//

#import <Foundation/Foundation.h>
@class Message;
@import Parse;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ChatSender) {
    ChatSenderMyself,
    ChatSenderSomeone
};

@interface Chat : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *chatDescription;
@property (nonatomic, strong) NSDate *date;

@property (nonatomic, strong) NSString *recipientName;
@property (nonatomic, strong) NSArray<PFUser *> *recipients;
@property (nonatomic, strong) PFFileObject *recipientImage;
@property (nonatomic, strong) PFUser *author;

@property (nonatomic, assign) NSInteger current_sender;

@property (nonatomic, strong) NSMutableArray<Message *> *messages;

+ (void) postChat: (NSString * _Nullable)chatDescription withRecipients:(NSArray<PFUser *> *)recipients withCompletion: (PFBooleanResultBlock  _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
