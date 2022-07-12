//
//  MessageCell.m
//  Whatsapp
//
//  Created by Guilherme David on 07/08/22.
//  Adapted from Rafael Castro
//

#import "MessageCell.h"
#import "EditMessageVC.h"
#import "Message.h"

@interface MessageCell ()
// Message
// @property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) UIImageView *bubbleImage;


@end

#define LAYER_HEIGHT 25
#define NUM_LAYERS 6

@implementation MessageCell

-(CGFloat) bubbleCellHeight {
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
    _moveButton = [UIButton new];
    _changeSenderButton = [UIButton new];
    _deleteButton = [UIButton new];

    // subviews for message bubble
    [self.contentView addSubview:_bubbleImage];
    [self.contentView addSubview:_textView];
    
    // Subviews for message container
    [self.contentView addSubview:_messageType];
    [self.contentView addSubview:_editButton];
    [self.contentView addSubview:_deleteButton];
    [self.contentView addSubview:_moveButton];
    [self.contentView addSubview:_changeSenderButton];
}

- (void) prepareForReuse {
    [super prepareForReuse];
    
    _textView.text = @"";
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
    //[self setMessageType];
    
   // [self setContainerButton:_editButton withTitle:@"Edit" withOrder:1 withMethod:@selector(aMethod:)];
    //[self setContainerButton:_changeSenderButton withTitle:@"Change sender" withOrder:2 withMethod:@selector(aMethod:)];
    //[self setContainerButton:_moveButton withTitle:@"Move" withOrder:3 withMethod:@selector(aMethod:)];
    //[self setContainerButton:_deleteButton withTitle:@"Delete" withOrder:4 withMethod:@selector(aMethod:)];

    [self setNeedsLayout];
}

#pragma mark - Container

- (void) setMessageType {
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
    CGFloat messageType_x = 10;
    CGFloat messageType_y = 0;
    
    // Get height and width of the UILabel based on the size of its text
    CGSize textSize = [text sizeWithAttributes:@{NSFontAttributeName:_textView.font}];
   
    _messageType.frame = CGRectMake(messageType_x, messageType_y, textSize.width, textSize.height);
}

- (void) setContainerButton:(UIButton *)button
                            withTitle:(NSString *)title
                            withOrder:(int)order
                            withMethod:(nonnull SEL)method {
    
    [button addTarget:self action:@selector(aMethod:) forControlEvents:UIControlEventTouchUpInside];
    
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
    
    /* if sender is someone else {
        textView_x = 20;
        textView_y = -1;
        autoresizing = UIViewAutoresizingFlexibleRightMargin;
    */
    
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
    
    /* if sender is someone else
        bubble_x = marginRight;
        
        _bubbleImage.image = [[self imageNamed:@"bubbleRecipient"]
                              stretchableImageWithLeftCapWidth:21 topCapHeight:14];
        
        bubble_width = _textView.frame.origin.x + _textView.frame.size.width + marginLeft;
    */
   
    _bubbleImage.frame = CGRectMake(bubble_x, bubble_y, bubble_width, bubble_height);
    _bubbleImage.autoresizingMask = _textView.autoresizingMask;
}


#pragma mark - UIImage Helper

- (UIImage *) imageNamed:(NSString *)imageName {
    return [UIImage imageNamed:imageName
                    inBundle:[NSBundle bundleForClass:[self class]]
                    compatibleWithTraitCollection:nil];
}

#pragma mark - Container methods


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"editMessageSegue"]) {
        Message *messageToPass = self.message;
        EditMessageVC *editMessageVC = [segue destinationViewController];
        editMessageVC.message = messageToPass;
    }
}


- (void)didTapLogout {
    return;
}

- (void) didTapDelete {
    
}



@end
