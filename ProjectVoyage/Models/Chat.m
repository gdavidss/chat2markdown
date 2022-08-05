//
//  Chat.m
//  ProjectVoyage
//
//  Created by Gui David on 7/6/22.
//

#import "Chat.h"
#import "GlobalVariables.h"
#import "Util.h"
// @import Parse;

@implementation Chat

@dynamic chatTitle;
@dynamic chatDescription;
@dynamic recipients;
@dynamic messages_3;
@dynamic current_sender;
@dynamic lastOrder;
@dynamic image;

+ (nonnull NSString *)parseClassName {
    return @"Chat";
}

+ (void) postChat: (NSString * _Nullable)chatTitle withDescription:(NSString * _Nullable)chatDescription withImage:(UIImage * _Nullable )image withRecipients:(NSArray<PFUser *> *)recipients withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    Chat *newChat = [Chat new];
    newChat.chatTitle = chatTitle;
    newChat.lastOrder = -1;
    newChat.recipients = recipients;
    newChat.chatDescription = chatDescription;
    newChat.current_sender = 0;
    newChat.image = [Util getPFFileFromImage:image];
    
    //[newChat pinInBackground];
    [newChat saveInBackgroundWithBlock: completion];
}

+ (NSMutableArray *) getMessagesArrayForChat:(Chat *)chat {
    PFRelation *chatMessagesRelation = [chat relationForKey:MESSAGES];
    PFQuery *query = [chatMessagesRelation query];
    
    NSArray *queryKeys = [NSArray arrayWithObjects:TEXT, SENDER, ORDER, nil];
    [query includeKeys:queryKeys];
    
    [query orderByAscending:ORDER];
    
    NSMutableArray *messagesArray = [NSMutableArray new];
    // Fetch data asynchronously
    __weak __typeof(self) weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray *messages, NSError *error) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        if (messages == nil) {
            NSLog(@"%@", error.localizedDescription);
        } else {
            [messagesArray addObjectsFromArray:messages];
        }
    }];
    return messagesArray;
}

@end
