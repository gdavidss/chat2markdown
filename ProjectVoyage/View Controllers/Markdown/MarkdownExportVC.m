//
//  MarkdownExportVC.m
//  ProjectVoyage
//
//  Created by Gui David on 7/15/22.
//

#import "MarkdownExportVC.h"
#import "Message.h"
@import Parse;
@import MarkdownView;


#define Myself ((BOOL)1)
#define Someone  ((BOOL)0)


/*
typedef NS_ENUM(NSInteger, MessageSender) {
    MessageSenderMyself,
    MessageSenderSomeone
};*/

@interface MarkdownExportVC ()
@property (nonatomic, strong) IBOutlet UIButton *mdCopyButton;
@property (nonatomic, strong) IBOutlet UITextView *textArea;
@property (weak, nonatomic) NSMutableArray<Message *> *messages;
@property (nonatomic, strong) NSMutableString *convertedMarkdown;
@property (weak, nonatomic) IBOutlet UIView *markdownView;

@end


@implementation MarkdownExportVC


- (void)viewDidLoad {
    [super viewDidLoad];
    _convertedMarkdown = [NSMutableString new];
    [_convertedMarkdown appendString:@"\n"];
    _messages = _chat.messages;

    [self appendMetadata];
    [self appendChat];

    NSLog(@"%@", _convertedMarkdown);
    
    MarkdownView *md = [MarkdownView new];
    [self.markdownView addSubview:md];
    md.frame = self.markdownView.bounds;
    [md loadWithMarkdown:_convertedMarkdown enableImage:YES css:nil plugins:nil stylesheets:nil styled:YES];
    
}

- (void) appendMetadata {
    NSString *chatId = [NSString stringWithFormat:@"%@: %@", @"**_Chat ID_**", _chat.chat_id];
    NSString *recipientName = [NSString stringWithFormat:@"%@: %@", @"**_Recipient Name_**", _chat.chat_id];
    NSString *chatDescription = [NSString stringWithFormat:@"%@: %@", @"**_Chat description_**", _chat.chat_id];

    [self generateBlock:@"Metadata" withIdentation:0 isItBold:YES];
    [self generateBlock:chatId withIdentation:1 isItBold:NO];
    [self generateBlock:recipientName withIdentation:1 isItBold:NO];
    [self generateBlock:chatDescription withIdentation:1 isItBold:NO];
   
    return;
}

- (void) appendChat {
    [self generateBlock:@"Messages" withIdentation:0 isItBold:YES];

    NSArray<Message *> *ordered_messages = [self orderMessages:_messages];
    bool last_sender = (ordered_messages[0].sender == MessageSenderMyself)? Myself: Someone;
    
    if (last_sender == Myself) {
        [self generateBlock:[PFUser currentUser].username withIdentation:1 isItBold:YES];
    } else {
        [self generateBlock:_chat.recipientName withIdentation:1 isItBold:YES];
    }
    
    for (Message *message in ordered_messages) {
        bool current_sender = (message.sender == MessageSenderMyself)? Myself: Someone;
        
        if (last_sender != current_sender) {
            if (current_sender == Myself) {
                [self generateBlock:[PFUser currentUser].username withIdentation:1 isItBold:YES];
            } else {
                [self generateBlock:_chat.recipientName withIdentation:1 isItBold:YES];
            }
        }
        
        [self generateBlock:message.text withIdentation:3 isItBold:NO];
        
        last_sender = current_sender;
    }
    return;
}

- (void)generateBlock:(NSString *)text withIdentation:(NSInteger)num_identation isItBold:(bool)bold {
    // Index of the array is equal to number of indentations
    NSArray<NSString *> *identations =
        [[NSArray alloc] initWithObjects:@"", @"  ", @"   ", @"    ", nil];
    
    NSString *format = bold? @"%@- **%@** %@": @"%@- %@ %@";
    
    NSMutableString *block = [NSMutableString new];
    [block appendFormat:format, identations[num_identation], text, @"\n"];
    [_convertedMarkdown appendString:(NSString *)block];
}

// Order messages from least recent to most recent
- (NSArray<Message *> *) orderMessages:(NSArray<Message *> *)messages {
    NSMutableArray *ordered_messages = [NSMutableArray new];
    for (Message *msg in messages) {
        [ordered_messages addObject:msg];
    }
    return (NSArray *)ordered_messages;
}

@end
