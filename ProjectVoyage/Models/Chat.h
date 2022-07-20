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

@property (nonatomic, strong) NSString *chatDescription;
@property (nonatomic, strong) NSDate *date;

@property (nonatomic, strong) NSString *recipientName;
@property (nonatomic, strong) PFFileObject *recipientImage;
@property (nonatomic, strong) PFUser *author;

@property (nonatomic, strong) NSMutableArray<Message *> *messages;

+ (void) postChat: (NSString * _Nullable)recipientDescription withRecipientName:(NSString *)recipientName withRecipientImage:(UIImage * _Nullable)recipientImg withCompletion: (PFBooleanResultBlock  _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
