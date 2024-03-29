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
    
    //[PFObject unpinAllObjects];
    //[chat unpin];
    [query whereKey:@"chatId" equalTo:chat.objectId];
    //[query fromPinWithName:chat.objectId];
    [query fromLocalDatastore];
    [query orderByAscending:@"order"];
    // NSArray<Message *> *cachedMessages = (NSArray *)[[query findObjects] copy];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        //[PFObject unpinAll:objects];
        NSArray<Message *> *cachedMessages = objects;
    }];
    
    //NSMutableOrderedSet *cachedMessagesSet = [NSMutableOrderedSet orderedSetWithArray:cachedMessages];
    // return cachedMessagesSet;
    return nil;
}

/* CC - this will be important later, but focusing on messages now
 
+ (NSArray *) retrieveCachedChats {
    PFQuery *query = [PFQuery queryWithClassName:CHAT_CLASS];
    [query orderByDescending:UPDATED_AT];
    [query fromLocalDatastore];
    
    NSArray *queryKeys = [NSArray arrayWithObjects:RECIPIENTS, CHAT_DESCRIPTION, MESSAGES, IMAGE, nil];
    [query includeKeys:queryKeys];
        
    [query whereKey:RECIPIENTS containsAllObjectsInArray:@[[PFUser currentUser]]];
    return [query findObjects];
}*/

+ (NSMutableOrderedSet *) retrieveMessagesToSync:(Chat *)chat {
    PFQuery *query = [PFQuery queryWithClassName:MESSAGES];
    
    NSString *syncQueueIdentifier = [self getSyncQueueIdentifierForChat:chat];
    [query fromPinWithName:syncQueueIdentifier];
    [query orderByDescending:ORDER];
    [query fromLocalDatastore];
    
    NSArray<Message *> *messagesToSync = [query findObjects];
    NSMutableOrderedSet *messagesToSyncSet = [NSMutableOrderedSet orderedSetWithArray:messagesToSync];
    
    return messagesToSyncSet;
}

+ (void) cacheMessagesInSyncQueue:(Message *)message forChat:(Chat *)chat {
    NSString *syncQueueIdentifier = [self getSyncQueueIdentifierForChat:chat];
    [message pinWithName:syncQueueIdentifier];
}

+ (NSString *) getSyncQueueIdentifierForChat:(Chat *)chat {
    return [NSString stringWithFormat:@"%@%@", chat.objectId, @":syncQueue", nil];
}

+ (void) resetCacheWithMessages:messages {
    [PFObject unpinAll:messages];
    [PFObject pinAll:messages];
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
