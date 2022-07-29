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

- (id)init {
    self = [super init];
    return self;
}

+ (nonnull NSString *)parseClassName {
    return @"Message";
}

+ (void) postMessage: (NSString * _Nullable)text withSender:(PFUser *)sender withHeight:(CGFloat)height withCompletion: (PFBooleanResultBlock  _Nullable)completion{
    Message *newMessage = [Message new];
    newMessage.sender = sender;
    newMessage.text = text;
    newMessage.height = height;
    [newMessage saveInBackgroundWithBlock: completion];
}

@end
