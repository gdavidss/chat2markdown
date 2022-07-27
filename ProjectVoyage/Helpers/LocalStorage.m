//
//  LocalStorage.m
//  Whatsapp
//
//  Created by Rafael Castro on 7/24/15.
//  Copyright (c) 2015 HummingBird. All rights reserved.
//

#import "LocalStorage.h"

@interface LocalStorage ()
@property (strong, nonatomic) NSMutableDictionary *mapChatToMessages;
@end

@implementation LocalStorage

+ (id)sharedInstance {
    static LocalStorage *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        self.mapChatToMessages = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(NSArray *)queryMessagesForChatID:(NSString *)chat_id {
    return [self.mapChatToMessages valueForKey:chat_id];
}

@end
