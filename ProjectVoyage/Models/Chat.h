//
//  Chat.h
//  ProjectVoyage
//
//  Created by Gui David on 7/6/22.
//

#import <Foundation/Foundation.h>
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@interface Chat : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *chatID;
@property (nonatomic, strong) NSString *chatDescription;
@property (nonatomic, strong) NSString *recipientName;
@property (nonatomic, strong) PFFileObject *recipientImage;
@property (nonatomic, strong) PFUser *author;

+ (void) postChat: (NSString * _Nullable)recipientDescription withRecipientName:(NSString *)recipientName withRecipientImage:(UIImage * _Nullable)recipientImg withCompletion: (PFBooleanResultBlock  _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
