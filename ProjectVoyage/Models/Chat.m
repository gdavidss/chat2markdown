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

@dynamic chatTitle;
@dynamic chatDescription;
@dynamic recipients;
@dynamic messages;
@dynamic current_sender;
@dynamic image;

+ (nonnull NSString *)parseClassName {
    return @"Chat";
}

+ (void) postChat: (NSString * _Nullable)chatTitle withDescription:(NSString * _Nullable)chatDescription withImage:(UIImage * _Nullable )image withRecipients:(NSArray<PFUser *> *)recipients withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    Chat *newChat = [Chat new];
    newChat.chatTitle = chatTitle;
    newChat.recipients = recipients;
    newChat.chatDescription = chatDescription;
    newChat.messages = [NSMutableArray new];
    newChat.current_sender = 0;
    newChat.image = [Util getPFFileFromImage:image];
    
    //[newChat pinInBackground];
    [newChat saveInBackgroundWithBlock: completion];
}

@end
