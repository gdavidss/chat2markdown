//
//  LocalStorage.m
//  ProjectVoyage
//
//  Created by Gui David on 8/3/22.
//

#import "Cache.h"
#import "GlobalVariables.h"
@import Parse;

@interface Cache ()
@end

@implementation Cache

- (id) init {
    self = [super init];
    return self;
}

+ (NSMutableOrderedSet *) retrieveCachedMessages:(Chat *)chat {
    PFQuery *query = [PFQuery queryWithClassName:MESSAGE_CLASS];
    [query fromPinWithName:chat.objectId];
    
    [query fromLocalDatastore];
    [query orderByAscending:@"order"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        NSArray<Message *> *cachedMessages = objects;
    }];
    
    //NSMutableOrderedSet *cachedMessagesSet = [NSMutableOrderedSet orderedSetWithArray:cachedMessages];
    
    return nil;
}

+ (NSArray *) retrieveCachedChats {
    PFQuery *query = [PFQuery queryWithClassName:CHAT_CLASS];
    [query orderByDescending:UPDATED_AT];
    [query fromLocalDatastore];
    
    NSArray *queryKeys = [NSArray arrayWithObjects:RECIPIENTS, CHAT_DESCRIPTION, MESSAGES, IMAGE, nil];
    [query includeKeys:queryKeys];
        
    [query whereKey:RECIPIENTS containsAllObjectsInArray:@[[PFUser currentUser]]];
    return [query findObjects];
}

/* CC - Old strategy of manually caching
+ (BOOL) isCacheFull:(NSMutableOrderedSet *)cachedMessages {
    return (cachedMessages.count == STORAGE_SIZE);
}

+ (NSMutableOrderedSet *) removeOldMessagesFromCache:(NSMutableOrderedSet *)cachedMessages {
    
    [cachedMessages reversedOrderedSet];
}
 */


@end
