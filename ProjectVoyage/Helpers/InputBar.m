//
//  InputBar.m
//  ProjectVoyage
//
//  Created by Gui David on 7/8/22.
//

#import "InputBar.h"
#import "HPGrowingTextView.h"

@interface Inputbar() <HPGrowingTextViewDelegate>
@property (nonatomic, strong) HPGrowingTextView *textView;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UIButton *changeSenderButton;

@end

#define BUTTON_SIZE 60

@implementation Inputbar

- (id) init {
    self = [super init];
    if (self) {
        [self addContent];
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addContent];
    }
    return self;
}

-  (id) initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self addContent];
    }
    return self;
}

- (void) addContent {
    [self addTextView];
    [self addButton:self.sendButton withLabel:@"Send" withMethod:@selector(didPressSendButton:) withOrder:1 isSelected:YES];
    [self addButton:self.changeSenderButton withLabel:@"Change" withMethod:@selector(didPressChangeSenderButton:) withOrder:2 isSelected:NO];
    
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
}

- (void) addTextView {
    CGSize size = self.frame.size;
    _textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(10,
                                                                    5,
                                                                    size.width - 10 - 3 * BUTTON_SIZE,
                                                                    size.height)];
    _textView.isScrollable = NO;
    _textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    
    _textView.minNumberOfLines = 1;
    _textView.maxNumberOfLines = 6;
    _textView.returnKeyType = UIReturnKeyGo; //just as an example
    _textView.font = [UIFont systemFontOfSize:15.0f];
    _textView.delegate = self;
    _textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    _textView.backgroundColor = [UIColor whiteColor];
    _textView.placeholder = _placeholder;
    
    /* CC - experimental attributes
     
    textView.maxHeight = 200.0f;
    textView.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    textView.scrollIndicatorInsets = UIEdgeInsetsMake(0.0, -1.0, 0.0, 1.0);
    textView.textContainerInset = UIEdgeInsetsMake(8.0, 4.0, 8.0, 0.0);
    */
    
    _textView.keyboardType = UIKeyboardTypeDefault;
    _textView.returnKeyType = UIReturnKeyDefault;
    _textView.enablesReturnKeyAutomatically = YES;
    
    _textView.layer.cornerRadius = 5.0;
    _textView.layer.borderWidth = 0.5;
    _textView.layer.borderColor =  [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:205.0/255.0 alpha:1.0].CGColor;
    
    _textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    // view hierachy
    [self addSubview:_textView];
}

#pragma mark - Buttons

- (void)addButton:(UIButton *)button withLabel:(NSString *)label withMethod:(nonnull SEL)method withOrder:(int)order isSelected:(BOOL)selection{
    CGSize size = self.frame.size;
    button = [[UIButton alloc] init];
    button.frame = CGRectMake(size.width - order * BUTTON_SIZE, 0, BUTTON_SIZE, size.height);
    button.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateSelected];
    [button setTitle:label forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    
    [button addTarget:self action:method forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:button];
    
    [button setSelected:selection];
}

-(void)resignFirstResponder {
    [_textView resignFirstResponder];
}

-(NSString *)text {
    return _textView.text;
}


#pragma mark - Delegate

- (void)didPressSendButton:(UIButton *)sender {
    if (self.sendButton.isSelected) return;
    
    [self.delegate inputbarDidPressSendButton:self];
    self.textView.text = @"";
}

- (void)didPressChangeSenderButton:(UIButton *)sender {
    if (self.changeSenderButton.isSelected) return;
    
    [self.delegate inputbarDidPressChangeSenderButton:self];
}

- (void)didPressLeftButton:(UIButton *)sender
{
    [self.delegate inputbarDidPressLeftButton:self];
}

#pragma mark - Set Methods

-(void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    _textView.placeholder = placeholder;
}

-(void)setSendButtonTextColor:(UIColor *)sendButtonTextColor {
    [self.sendButton setTitleColor:sendButtonTextColor forState:UIControlStateNormal];
}

-(void)setSendButtonText:(NSString *)sendButtonText {
    [self.sendButton setTitle:sendButtonText forState:UIControlStateNormal];
}

#pragma mark - TextViewDelegate

-(void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height {
    float diff = (growingTextView.frame.size.height - height);
    
    CGRect r = self.frame;
    r.size.height -= diff;
    r.origin.y += diff;
    self.frame = r;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputbarDidChangeHeight:)])
    {
        [self.delegate inputbarDidChangeHeight:self.frame.size.height];
    }
}

-(void)growingTextViewDidBeginEditing:(HPGrowingTextView *)growingTextView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputbarDidBecomeFirstResponder:)]) {
        [self.delegate inputbarDidBecomeFirstResponder:self];
    }
}

- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView {
    NSString *text = [growingTextView.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([text isEqualToString:@""])
        [self.sendButton setSelected:YES];
    else
        [self.sendButton setSelected:NO];
}
@end
