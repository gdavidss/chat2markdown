//
//  NetworkManager.m
//  ProjectVoyage
//
//  Created by Gui David on 8/3/22.
//

#import "NetworkManager.h"
#import "Reachability.h"

@interface NetworkManager ()
@end

@implementation NetworkManager

+ (NetworkManager *)shared {
    static NetworkManager *_sharedManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });

    return _sharedManager;
}

- (void)checkConnection {
    self.reachable = [Reachability reachabilityWithHostname:@"www.google.com"];
    [self.reachable startNotifier];
    self.isAppOnline = [self.reachable isReachable];
}

- (void)reachabilityChanged {
    self.isAppOnline = [self.reachable isReachable];
    // This is where I should sync objects created offline
    
}

@end

