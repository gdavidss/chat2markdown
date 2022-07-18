//
//  ChatCell.m
//  ProjectVoyage
//
//  Created by Gui David on 7/8/22.
//

#import "ChatCell.h"
#import "Util.h"

@implementation ChatCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}


- (void) setChat:(Chat *)chat {
    _chat = chat;
    self.recipientImage.image = [UIImage imageWithData:[chat.recipientImage getData]];
    self.recipientLabel.text = chat.recipientName;
    self.descriptionLabel.text = chat.description;
    
    self.dateChat.text = [Util formatDateString:chat.createdAt];
}

@end

