//
//  Chat.m
//  ProjectVoyage
//
//  Created by Gui David on 7/6/22.
//

#import "Chat.h"
#import "Util.h"
@import Parse;

@implementation Chat

@dynamic description;
@dynamic date;
@dynamic recipientName;
@dynamic recipientImage;
@dynamic author;
@dynamic messages;


+ (nonnull NSString *)parseClassName {
    return @"Chat";
}


+ (void) postChat: (NSString * _Nullable)chatDescription withRecipientName:(NSString *)recipientName withRecipientImage:(UIImage * _Nullable)recipientImg withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    Chat *newChat = [Chat new];
    newChat.recipientImage = [Util getPFFileFromImage:recipientImg];
    newChat.recipientName = recipientName;
    newChat.date = [NSDate new];
    newChat.chatDescription = chatDescription;
    newChat.messages = [NSMutableArray new];
    
    PFUser *currentUser = [PFUser currentUser];
    newChat.author = currentUser;
    
    [newChat saveInBackgroundWithBlock: completion];
}

@end
