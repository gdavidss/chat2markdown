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

@interface MarkdownExportVC ()
@property (nonatomic, weak) NSMutableArray<Message *> *messages;
@property (nonatomic, strong) NSMutableString *convertedMarkdown;
@property (nonatomic, strong) IBOutlet UIView *markdownView;

@end


@implementation MarkdownExportVC


- (void)viewDidLoad {
    [super viewDidLoad];
    _convertedMarkdown = [NSMutableString new];
    [_convertedMarkdown appendString:@"\n"];
    _messages = _chat.messages;

    [self appendMetadata];
    if ([_messages count] != 0) {
        [self appendChat];
    }
    
    MarkdownView *md = [MarkdownView new];
    [self.markdownView addSubview:md];
    md.frame = self.markdownView.bounds;
    [md loadWithMarkdown:_convertedMarkdown enableImage:YES css:nil plugins:nil stylesheets:nil styled:YES];
}

- (void) appendMetadata {
    NSString *recipientName = [NSString stringWithFormat:@"%@: %@", @"**Recipient Name**", _chat.recipientName];
    NSString *chatDescription = [NSString stringWithFormat:@"%@: %@", @"**Chat Description**", _chat.chatDescription];
    NSString *chatDate = [NSString stringWithFormat:@"%@: %@", @"**Date**", _chat.date];
    NSString *chatId = [NSString stringWithFormat:@"%@: %@", @"**Chat ID**", _chat.objectId];

    [self generateBlock:@"Metadata" withIdentation:0 isItBold:YES];
    [self generateBlock:recipientName withIdentation:1 isItBold:NO];
    [self generateBlock:chatDescription withIdentation:1 isItBold:NO];
    [self generateBlock:chatDate withIdentation:1 isItBold:NO];
    [self generateBlock:chatId withIdentation:1 isItBold:NO];
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
        bool current_sender = (message.isSenderMyself)? Myself: Someone;
        
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
}

- (void)generateBlock:(NSString *)text withIdentation:(NSInteger)num_identation isItBold:(bool)bold {
    // Index of the array is equal to number of indentations
    NSArray<NSString *> *identations =
        [[NSArray alloc] initWithObjects:@"", @"  ", @"   ", @"    ", nil];
    
    NSString *format = bold? @"%@- **%@**%@": @"%@- %@%@";
    
    NSMutableString *block = [NSMutableString new];
    [block appendFormat:format, identations[num_identation], text, @"\n"];
    [_convertedMarkdown appendString:(NSString *)block];
}

- (IBAction)didPressCopy:(id)sender {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = _convertedMarkdown;
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
