//
//  NetworkManager.h
//  ProjectVoyage
//
//  Created by Gui David on 8/3/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class Reachability;

@interface NetworkManager : NSObject

+ (NetworkManager *)shared;
@property(nonatomic, strong) Reachability *reachable;
@property(nonatomic, assign) BOOL isAppOnline;
- (void)checkConnection;

@end

NS_ASSUME_NONNULL_END
