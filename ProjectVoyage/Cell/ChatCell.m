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
    _chatTitle.text = chat.chatTitle;
    _descriptionLabel.text = chat.chatDescription;
    _dateChat.text = [Util formatDateString:chat.createdAt];

    self.layer.cornerRadius = 8;
    self.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.layer.shadowOffset = CGSizeMake(2, 2);
    // CGSize(width: 2.0, height: 2.0)
    
    self.layer.masksToBounds = YES;
    self.layer.shadowOpacity = 0.8;
    self.layer.shadowRadius = 8;
    
    [Util roundImage:_chatImage];

    //self.layer.borderWidth = 4;
    //self.layer.borderColor = [[UIColor blackColor] CGColor];
    self.layer.cornerRadius = self.frame.size.height / 4;
}

@end

