//
//  MarkdownExportVC.m
//  ProjectVoyage
//
//  Created by Gui David on 7/15/22.
//

#import "MarkdownExportVC.h"
#import "Message.h"
@import Parse;

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
    [_convertedMarkdown appendString:@"**Metadata**\n"];
    
    // GD test
    bool TEST_MODE = YES;
    if (TEST_MODE) {
        Chat *chat = [Chat new];
        chat.chat_id = @"42";
        chat.recipientName = @"Varun";
        chat.description = @"A conversation about debugging.";
        // chat.date = [NSDate date];
        _chat = chat;
    }

    [self appendMetadata];
    [self appendChat];

    NSLog(@"%@", _convertedMarkdown);
}

- (void) appendMetadata {
    // each index on the array corresponds to number of identations
    [self generateBlock:_chat.chat_id withIdentation:1];
    [self generateBlock:_chat.recipientName withIdentation:1];
    [self generateBlock:_chat.description withIdentation:1];
    // GD bug here that is printing a whole chat object instead of description wtf
    //[_convertedMarkdown appendString:[self generateBlock:_chat.description withIdentation:1]];
    //NSLog(@"%@", _convertedMarkdown);
    return;
}

- (void) appendChat {
    NSArray<Message *> *ordered_messages = [self orderMessages:_messages];
    bool last_sender = ordered_messages[0].isSenderMyself;
    
    NSMutableString *block = [NSMutableString new];
    for (Message *message in ordered_messages) {
        (MessageSender) current_sender message.sender;
        
        if (wasLastSenderMyself == isCurrentSenderMyself) {
            [self generateBlock:message.text withIdentation:1];
        } else {
            if (current_sender == MessageSenderMyself) {
                [self generateBlock:[PFUser currentUser].username withIdentation:0];
            } else {
                [self generateBlock:_chat.recipientName withIdentation:0];
            }
        }
    }
    return;
}

- (void)generateBlock:(NSString *)text withIdentation:(NSInteger)num_identation {
    NSArray<NSString *> *identations =
        [[NSArray alloc] initWithObjects:@"", @"  ", @"   ", @"    ", nil];
    
    NSMutableString *block = [NSMutableString new];
    [block appendFormat:@"%@ %@ %@", identations[num_identation], text, @"\n"];
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
