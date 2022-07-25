//
//  InputBar.h
//  ProjectVoyage
//
//  Created by Gui David on 7/8/22.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//
// Thanks for HansPinckaers for creating an amazing
// Growing UITextView. This class just add design and
// notifications to uitoobar be similar to whatsapp
// inputbar.
//
// https://github.com/HansPinckaers/GrowingTextView
//

@protocol InputbarDelegate;


@interface Inputbar : UIToolbar

@property (nonatomic, assign) id<InputbarDelegate> delegate;
@property (nonatomic) NSString *placeholder;
@property (nonatomic) UIImage *leftButtonImage;
@property (nonatomic) NSString *sendButtonText;
@property (nonatomic) UIColor  *sendButtonTextColor;

-(void)resignFirstResponder;
-(NSString *)text;

@end

@protocol InputbarDelegate <NSObject>

- (void) inputbarDidPressSendButton:(Inputbar *)inputbar;
- (void) inputbarDidPressChangeSenderButton:(Inputbar *)inputbar;
- (void) inputbarDidPressLeftButton:(Inputbar *)inputbar;

@optional
- (void) inputbarDidChangeHeight:(CGFloat)new_height;
- (void) inputbarDidBecomeFirstResponder:(Inputbar *)inputbar;

@end

NS_ASSUME_NONNULL_END
