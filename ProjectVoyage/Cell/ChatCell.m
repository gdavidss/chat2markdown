//
//  ChatCell.m
//  ProjectVoyage
//
//  Created by Gui David on 7/8/22.
//

#import "ChatCell.h"
#import "Util.h"

@interface ChatCell()
@property (nonatomic, strong) IBOutlet UILabel *chatTitle;
@property (nonatomic, strong) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, strong) IBOutlet UIImageView *chatImage;
@property (nonatomic, strong) IBOutlet UILabel *dateChat;
@end

@implementation ChatCell

- (void) setChat:(Chat *)chat {
    _chat = chat;

    _chatImage.image = [UIImage imageWithData:[chat.image getData]];
    NSString *chat_title = [NSString stringWithFormat:@"%@ & %@", chat.recipients[0].username, chat.recipients[1].username];
    _chatTitle.text = chat_title;
    _descriptionLabel.text = chat.chatDescription;
    _dateChat.text = [Util formatDateString:chat.createdAt];
    
    [Util roundImage:_chatImage];
}

@end

