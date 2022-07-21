//
//  MessageCell.m
//  Whatsapp
//
//  Created by Guilherme David on 07/08/22.
//  Adapted from Rafael Castro
//

#import "MessageCell.h"
#import "Message.h"

@interface MessageCell ()
// Container
@property (nonatomic, strong) UILabel *messageType;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIImageView *bubbleImage;
@end

#define LAYER_HEIGHT 25
#define NUM_LAYERS 4

@implementation MessageCell

-(CGFloat) minHeight {
    return LAYER_HEIGHT * NUM_LAYERS;
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
    
    _textView = [UITextView new];
    _bubbleImage = [UIImageView new];
    _messageType = [UILabel new];
    _editButton = [UIButton new];
    
    // subviews for message bubble
    [self.contentView addSubview:_bubbleImage];
    [self.contentView addSubview:_textView];
    
    // subviews for message container
    [self.contentView addSubview:_messageType];
    [self.contentView addSubview:_editButton];
}

- (void) prepareForReuse {
    [super prepareForReuse];
    
    _textView.text = @"";
    _bubbleImage.image = nil;
}

- (void) setMessage:(Message *)message {
    _message = message;
    [self buildCell];
    
    if (message.height < self.minHeight) {
        message.height = self.minHeight;
    }
}

- (void) buildCell {
    [self setupTextView];
    [self setupMessage];
    [self setupBubbleView];
    
    [self setContainerButton:_editButton withTitle:@"Edit" withOrder:1 withMethod:@selector(didTapEdit)];
    [self setNeedsLayout];
}

#pragma mark - Container

- (void) setupMessage {
    UIFont *customFont = [UIFont fontWithName:@"Helvetica" size:15.0];
    NSString *text = @"Written message";
    
    _messageType.font = customFont;
    _messageType.numberOfLines = 1;
    _messageType.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    _messageType.adjustsFontSizeToFitWidth = YES;
    _messageType.minimumScaleFactor = 10.0f/12.0f;
    _messageType.clipsToBounds = YES;
    _messageType.backgroundColor = [UIColor clearColor];
    _messageType.textColor = [UIColor grayColor];
    _messageType.textAlignment = NSTextAlignmentLeft;
    _messageType.text = text;
    
    // Position
    CGFloat messageType_x;
    CGFloat messageType_y = 0;
    
    // Get height and width of the UILabel based on the size of its text
    CGSize textSize = [text sizeWithAttributes:@{NSFontAttributeName:_textView.font}];
    
    if (_message.sender == MessageSenderMyself) {
        messageType_x = 10;
    } else {
        messageType_x = self.contentView.frame.size.width - textSize.width/2;
    }
    
    _messageType.frame = CGRectMake(messageType_x, messageType_y, textSize.width, textSize.height);
}

- (void) setContainerButton:(UIButton *)button
                  withTitle:(NSString *)title
                  withOrder:(int)order
                 withMethod:(nonnull SEL)method {
    
    [button addTarget:self action:method forControlEvents:UIControlEventTouchUpInside];
    
    button.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor linkColor] forState:UIControlStateNormal];
    
    // Margin from the UI label above
    CGFloat margin_y = 25 * order;
    
    CGFloat button_y = _messageType.frame.origin.y + margin_y;
    CGFloat button_x = _messageType.frame.origin.x;
    
    // GD Make the width dynamic depending on the label width of each button
    button.frame = CGRectMake(button_x, button_y, 120, 18);
}

#pragma mark - TextView

- (void) setupTextView {
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
    
    if (_message.sender == MessageSenderMyself) {
        textView_x = self.contentView.frame.size.width - textView_w - 20;
        textView_y = -3;
        autoresizing = UIViewAutoresizingFlexibleLeftMargin;
    } else {
        textView_x = 20;
        textView_y = -1;
        autoresizing = UIViewAutoresizingFlexibleRightMargin;
    }
    
    _textView.autoresizingMask = autoresizing;
    _textView.frame = CGRectMake(textView_x, textView_y, textView_w, textView_h);
}

#pragma mark - Bubble

- (void) setupBubbleView {
    // Margins
    CGFloat marginLeft = 5;
    CGFloat marginRight = 2;
    
    // Position
    CGFloat bubble_x;
    CGFloat bubble_y = 0;
    CGFloat bubble_width;
    CGFloat bubble_height = _textView.frame.size.height + 8;
    
    if (_message.sender == MessageSenderMyself) {
        // Set bubble image
        _bubbleImage.image = [[self imageNamed:@"bubbleSender"]
                              stretchableImageWithLeftCapWidth:15 topCapHeight:14];
        
        bubble_x = _textView.frame.origin.x - marginLeft;
        bubble_width = self.contentView.frame.size.width - bubble_x - marginRight;
        
    } else {
        bubble_x = marginRight;
        
        _bubbleImage.image = [[self imageNamed:@"bubbleRecipient"]
        stretchableImageWithLeftCapWidth:15 topCapHeight:14];
        
        bubble_width = _textView.frame.origin.x + _textView.frame.size.width + marginLeft;
    }
    _bubbleImage.frame = CGRectMake(bubble_x, bubble_y, bubble_width, bubble_height);
    _bubbleImage.autoresizingMask = _textView.autoresizingMask;
    
    if (bubble_height > _message.height) {
        _message.height = bubble_height;
    }
}

#pragma mark - UIImage Helper

- (UIImage *) imageNamed:(NSString *)imageName {
    return [UIImage imageNamed:imageName
                      inBundle:[NSBundle bundleForClass:[self class]]
 compatibleWithTraitCollection:nil];
}

#pragma mark - Container methods

- (void)didTapEdit {
    [self.delegate editMessage:self.message];
    return;
}

@end
