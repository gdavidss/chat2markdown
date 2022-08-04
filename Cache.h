//
//  Cache.h
//  ProjectVoyage
//
//  Created by Gui David on 8/3/22.
//

#import <Foundation/Foundation.h>
#import "Chat.h"

NS_ASSUME_NONNULL_BEGIN

@interface Cache : NSObject

@property PFObject *cache;

+ (NSMutableOrderedSet *) retrieveCachedMessages:(Chat *)chat;

@end

NS_ASSUME_NONNULL_END
