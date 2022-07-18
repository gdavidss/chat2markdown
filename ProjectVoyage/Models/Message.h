//
//  Message.h
//  ProjectVoyage
//
//  Created by Gui David on 7/8/22.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Chat.h"

NS_ASSUME_NONNULL_BEGIN

typedef bool last_sender {
    myself = TRUE,
    someone = FALSE
};

@interface Message : NSObject

@property (assign, nonatomic) bool isSenderMyself;
@property (strong, nonatomic) NSString *identifier;

@property (strong, nonatomic) NSString *chatId;
@property (strong, nonatomic) NSString *text;

// GD isn't this redundant? I think order is more important than date for displaying it correctly.
@property (strong, nonatomic) NSDate *date;

// GD why do I need height here? Reconsider this being handled automatically by message cell
@property (assign, nonatomic) CGFloat height;

+(Message *)messageFromDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
