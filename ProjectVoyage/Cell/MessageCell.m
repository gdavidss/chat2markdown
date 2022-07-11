//
//  MessageCell.m
//  Whatsapp
//
//  Created by Guilherme David on 07/08/22.
//  Adapted from Rafael Castro
//

#import "MessageCell.h"

@interface MessageCell ()
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) UIImageView *bubbleImage;
@property (strong, nonatomic) UIImageView *statusIcon;

@property (strong, nonatomic) UILabel *messageType;
@end


@implementation MessageCell

-(CGFloat) bubbleCellHeight {
    return _bubbleImage.frame.size.height;
}

#pragma mark - Initialization

- (id) init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void) commonInit {
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.accessoryType = UITableViewCellAccessoryNone;
    
    _textView = [[UITextView alloc] init];
    _bubbleImage = [[UIImageView alloc] init];
    _messageType = [[UILabel alloc] init];
    
    [self.contentView addSubview:_bubbleImage];
    [self.contentView addSubview:_textView];
    [self.contentView addSubview:_messageType];
}

- (void) prepareForReuse {
    [super prepareForReuse];
    
    _textView.text = @"";
    _timeLabel.text = @"";
    _bubbleImage.image = nil;
}

- (void) setMessage:(Message *)message {
    _message = message;
    [self buildCell];
    
    message.height = self.bubbleCellHeight;
}

- (void) buildCell {
    [self setTextView];
    [self setBubble];
    [self setMessageType];
    [self setNeedsLayout];
}

#pragma mark - Container

- (void) setMessageType {
    UIFont * customFont = [UIFont fontWithName:@"Helvetica" size:15.0]; //custom font
    NSString *text = @"Written message";

    _messageType.font = customFont;
    _messageType.numberOfLines = 1;
    _messageType.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    _messageType.adjustsFontSizeToFitWidth = YES;
    _messageType.adjustsLetterSpacingToFitWidth = YES;
    _messageType.minimumScaleFactor = 10.0f/12.0f;
    _messageType.clipsToBounds = YES;
    _messageType.backgroundColor = [UIColor clearColor];
    _messageType.textColor = [UIColor grayColor];
    _messageType.textAlignment = NSTextAlignmentLeft;
    _messageType.text = text;
    
    // Margins
    CGFloat marginRight = 2;
    
    // Position
    CGFloat messageType_x = 10;
    CGFloat messageType_y = 0;
    CGFloat messageType_width;
    CGFloat messageType_height = 40;
    
    messageType_width = self.contentView.frame.size.width - messageType_x - marginRight;
   
    _messageType.frame = CGRectMake(messageType_x, messageType_y, messageType_width, messageType_height);
}


#pragma mark - TextView

- (void) setTextView {
    CGFloat max_width = 0.5 * self.contentView.frame.size.width;
    _textView.frame = CGRectMake(0, 0, max_width, MAXFLOAT);
    _textView.font = [UIFont fontWithName:@"Helvetica" size:17.0];
    _textView.backgroundColor = [UIColor clearColor];
    _textView.userInteractionEnabled = NO;
    
    _textView.text = _message.text;
    [_textView sizeToFit];
    
    CGFloat textView_x;
    CGFloat textView_y;
    CGFloat textView_w = _textView.frame.size.width;
    CGFloat textView_h = _textView.frame.size.height;
    UIViewAutoresizing autoresizing;
    
    textView_x = self.contentView.frame.size.width - textView_w - 20;
    textView_y = -3;
    autoresizing = UIViewAutoresizingFlexibleLeftMargin;
        
    _textView.autoresizingMask = autoresizing;
    _textView.frame = CGRectMake(textView_x, textView_y, textView_w, textView_h);
}

#pragma mark - Bubble

- (void) setBubble {
    // Set bubble image
    _bubbleImage.image = [[self imageNamed:@"bubbleSender"]
                          stretchableImageWithLeftCapWidth:15 topCapHeight:14];
    
    // Margins
    CGFloat marginLeft = 5;
    CGFloat marginRight = 2;
    
    // Position
    CGFloat bubble_x;
    CGFloat bubble_y = 0;
    CGFloat bubble_width;
    CGFloat bubble_height = _textView.frame.size.height + 8;
    
    bubble_x = _textView.frame.origin.x - marginLeft;
    
    bubble_width = self.contentView.frame.size.width - bubble_x - marginRight;
    
   
    _bubbleImage.frame = CGRectMake(bubble_x, bubble_y, bubble_width, bubble_height);
    _bubbleImage.autoresizingMask = _textView.autoresizingMask;
}


#pragma mark - UIImage Helper

- (UIImage *) imageNamed:(NSString *)imageName {
    return [UIImage imageNamed:imageName
                    inBundle:[NSBundle bundleForClass:[self class]]
                    compatibleWithTraitCollection:nil];
}

@end
