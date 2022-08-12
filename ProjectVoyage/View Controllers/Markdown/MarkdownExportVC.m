//
//  MarkdownExportVC.m
//  ProjectVoyage
//
//  Created by Gui David on 7/15/22.
//

#import "MarkdownExportVC.h"
#import "GlobalVariables.h"
#import "NetworkManager.h"
#import "Util.h"
#import "Message.h"
@import Parse;
@import MarkdownView;

#define Myself ((BOOL)1)
#define Someone  ((BOOL)0)

@interface MarkdownExportVC ()
@property (nonatomic, strong) NSMutableString *convertedMarkdown;
@property (nonatomic, strong) IBOutlet UIView *markdownView;

@end

@implementation MarkdownExportVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _convertedMarkdown = [NSMutableString new];
    [_convertedMarkdown appendString:@"\n"];
    _messages = [Chat getMessagesArrayForChat:_chat];

    [self appendMetadata];
    
    if ([[NetworkManager shared] isAppOnline]) {
        [self retrieveAllMessages];
    }
    
    if ([_messages count] != 0) {
        [self appendChat];
    }
    
    MarkdownView *md = [MarkdownView new];
    [self.markdownView addSubview:md];
    md.frame = self.markdownView.bounds;
    [md loadWithMarkdown:_convertedMarkdown enableImage:YES css:nil plugins:nil stylesheets:nil styled:YES];
}

- (void) appendMetadata {
    NSString *chat_title = [NSString stringWithFormat:@"%@, %@", _chat.recipients[0][NAME], _chat.recipients[1][NAME]];
    
    NSString *recipientName = [NSString stringWithFormat:@"%@: %@", @"**Recipients**", chat_title];
    NSString *chatDescription = [NSString stringWithFormat:@"%@: %@", @"**Chat Description**", _chat.chatDescription];
    NSString *chatDate = [NSString stringWithFormat:@"%@: %@", @"**Date**", [Util formatDateString:_chat.createdAt]];
    NSString *chatId = [NSString stringWithFormat:@"%@: %@", @"**Chat ID**", _chat.objectId];

    [self generateBlock:@"Metadata" withIdentation:0 isItBold:YES];
    [self generateBlock:recipientName withIdentation:1 isItBold:NO];
    if (![_chat.chatDescription isEqual:@""]) {
        [self generateBlock:chatDescription withIdentation:1 isItBold:NO];
    }
    [self generateBlock:chatDate withIdentation:1 isItBold:NO];
    [self generateBlock:chatId withIdentation:1 isItBold:NO];
}

- (void) retrieveAllMessages {
    PFRelation *chatMessagesRelation = [_chat relationForKey:MESSAGES];
    PFQuery *query = [chatMessagesRelation query];
    
    NSArray *queryKeys = [NSArray arrayWithObjects:TEXT, SENDER, ORDER, nil];
    
    [query includeKeys:queryKeys];
    [query orderByAscending:ORDER];
    
    // Fetch data asynchronously
    NSArray *messagesArray = [query findObjects];
    _messages = (NSMutableArray<Message *> *)messagesArray;
}

- (void) appendChat {
    [self generateBlock:@"Messages" withIdentation:0 isItBold:YES];

    NSArray<Message *> *ordered_messages = [self orderMessages:_messages];
    NSString *lastSender = ordered_messages[0].sender.objectId;
    
    if ([lastSender isEqual:[PFUser currentUser].objectId]) {
        [self generateBlock:[PFUser currentUser][NAME] withIdentation:1 isItBold:YES];
    } else {
        [self generateBlock:_otherRecipientUsername withIdentation:1 isItBold:YES];
    }
    
    for (Message *message in ordered_messages) {
        NSString *currentSender = message.sender.objectId;
        
        if (![lastSender isEqual:currentSender]) {
            if ([currentSender isEqual:[PFUser currentUser].objectId]) {
                [self generateBlock:[PFUser currentUser][NAME] withIdentation:1 isItBold:YES];
            } else {
                [self generateBlock:_otherRecipientUsername withIdentation:1 isItBold:YES];
            }
        }
        
        [self generateBlock:message.text withIdentation:3 isItBold:NO];
        lastSender = currentSender;
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
