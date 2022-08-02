//
//  Chat.m
//  ProjectVoyage
//
//  Created by Gui David on 7/6/22.
//

#import "Chat.h"
#import "Util.h"
// @import Parse;

@implementation Chat

@dynamic chatDescription;
@dynamic author;
@dynamic recipients;
@dynamic messages;
@dynamic current_sender;
@dynamic image;

+ (nonnull NSString *)parseClassName {
    return @"Chat";
}

+ (void) postChat: (NSString * _Nullable)chatDescription withImage:(UIImage * _Nullable )image withRecipients:(NSArray<PFUser *> *)recipients withCompletion: (PFBooleanResultBlock  _Nullable)completion{
    Chat *newChat = [Chat new];
    newChat.recipients = recipients;
    newChat.messages = [NSMutableArray new];
    newChat.current_sender = ChatSenderMyself;
    newChat.image = [Util getPFFileFromImage:image];
    
    [newChat pinInBackground];
    [newChat saveInBackgroundWithBlock: completion];
}

@end
