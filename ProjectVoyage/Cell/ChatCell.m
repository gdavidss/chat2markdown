//
//  ChatCell.m
//  ProjectVoyage
//
//  Created by Gui David on 7/8/22.
//

#import "ChatCell.h"
#import "Util.h"

@interface ChatCell()
@property (nonatomic, strong) IBOutlet UILabel *recipientLabel;
@property (nonatomic, strong) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, strong) IBOutlet UIImageView *recipientImage;
@property (nonatomic, strong) IBOutlet UILabel *dateChat;
@end

@implementation ChatCell

- (void) setChat:(Chat *)chat {
    _chat = chat;

    _recipientImage.image = [UIImage imageWithData:[chat.recipientImage getData]];
    _recipientLabel.text = chat.recipientName;
    _descriptionLabel.text = chat.chatDescription;
    _dateChat.text = [Util formatDateString:chat.createdAt];
    
    [Util roundImage:_recipientImage];
}

@end

