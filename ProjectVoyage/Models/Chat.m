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

@dynamic chatID;
@dynamic chatDescription;
@dynamic recipientName;
@dynamic recipientImg;
@dynamic author;

+ (nonnull NSString *)parseClassName {
    return @"Post";
}

+ (void) postChat: (NSString * _Nullable)chatDescription withRecipientName:(NSString *)recipientName withRecipientImage:(UIImage * _Nullable)recipientImg withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    Chat *newChat = [Chat new];
    newChat.recipientImg = [Util getPFFileFromImage:recipientImg];
    newChat.recipientName = recipientName;
    newChat.chatDescription = chatDescription;
    
    PFUser *currentUser = [PFUser currentUser];
    newChat.author = currentUser;
    
    [newChat saveInBackgroundWithBlock: completion];
}

@end
