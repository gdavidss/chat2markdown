//
//  MarkdownExportVC.m
//  ProjectVoyage
//
//  Created by Gui David on 7/15/22.
//

#import "MarkdownExportVC.h"
#import "Message.h"
@import Parse;


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

@end


@implementation MarkdownExportVC


- (void)viewDidLoad {
    [super viewDidLoad];
    _convertedMarkdown = [NSMutableString new];
    [_convertedMarkdown appendString:@"\n"];
    _messages = _chat.messages;
    
    // GD test
    bool TEST_MODE = NO;
    if (TEST_MODE) {
        Chat *chat = [Chat new];
        chat.chat_id = @"42";
        chat.recipientName = @"Varun";
        chat.chatDescription = @"A conversation about debugging.";
        // chat.date = [NSDate date];
        _chat = chat;
    }

    [self appendMetadata];
    [self appendChat];

    NSLog(@"%@", _convertedMarkdown);
}

- (void) appendMetadata {
    // each index on the array corresponds to number of identations
    [self generateBlock:@"Metadata" withIdentation:0 isItBold:YES];
    [self generateBlock:_chat.chat_id withIdentation:1 isItBold:NO];
    [self generateBlock:_chat.recipientName withIdentation:1 isItBold:NO];
    [self generateBlock:_chat.chatDescription withIdentation:1 isItBold:NO];
    // GD bug here that is printing a whole chat object instead of description wtf
    //[_convertedMarkdown appendString:[self generateBlock:_chat.description withIdentation:1]];
    //NSLog(@"%@", _convertedMarkdown);
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
        
        [self generateBlock:message.text withIdentation:2 isItBold:NO];
        
        last_sender = current_sender;
    }
    return;
}

- (void)generateBlock:(NSString *)text withIdentation:(NSInteger)num_identation isItBold:(bool)bold {
    NSArray<NSString *> *identations =
        [[NSArray alloc] initWithObjects:@"", @"  ", @"   ", @"    ", nil];
    
    NSString *format;
    if (bold) {
        format = @"%@ **%@** %@";
    } else {
        format = @"%@ %@ %@";
    }
    
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

/*
- (void) didChangeSender:(MessageSender)current_sender withLastSender:(MessageSender)last_sender {
    
    if (last_sender == current_sender) {
        [block appendFormat:@"%@ %@ %@", num_identation[0], [PFUser currentUser], @":\n"];
    } else {
        [block appendFormat:@"%@ %@ %@", num_identation[0], text, @"\n"];
    }
}*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
