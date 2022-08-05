//
//  Chat.h
//  ProjectVoyage
//
//  Created by Gui David on 7/6/22.
//

#import <Foundation/Foundation.h>
@class Message;
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@interface Chat : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *chatTitle;
@property (nonatomic, strong) NSString *chatDescription;

@property (nonatomic, strong) NSArray<PFUser *> *recipients;
@property (nonatomic, strong) PFFileObject *image;

@property (nonatomic, strong) PFRelation *messages_3;

@property (nonatomic, assign) NSInteger lastOrder;
@property (nonatomic, assign) NSInteger current_sender;

+ (void) postChat: (NSString * _Nullable)chatTitle withDescription:(NSString * _Nullable)chatDescription withImage:(UIImage * _Nullable )image withRecipients:(NSArray<PFUser *> *)recipients withCompletion: (PFBooleanResultBlock  _Nullable)completion;

+ (NSMutableArray *) getMessagesArrayForChat:(Chat *)chat;

@end

NS_ASSUME_NONNULL_END
