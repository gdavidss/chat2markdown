//
//  Message.m
//  ProjectVoyage
//
//  Created by Gui David on 7/8/22.
//

#import "Message.h"

@implementation Message

@dynamic sender;
@dynamic text;
@dynamic height;
@dynamic order;
@dynamic chatId;

- (id)init {
    self = [super init];
    return self;
}

- (BOOL)isEqual:(Message *)message {
    return [self.objectId isEqual:message.objectId];
}

+ (nonnull NSString *)parseClassName {
    return @"Message";
}

+ (void) postMessage: (NSString * _Nullable)text withSender:(PFUser *)sender withHeight:(CGFloat)height
           withOrder:(NSInteger)order withCompletion: (PFBooleanResultBlock  _Nullable)completion withChatId:(NSString *)chatId{
    Message *newMessage = [Message new];
    newMessage.sender = sender;
    newMessage.text = text;
    newMessage.height = height;
    newMessage.order = order;
    newMessage.chatId = chatId;
    [newMessage saveInBackgroundWithBlock: completion];
}


@end
