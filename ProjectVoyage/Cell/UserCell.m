//
//  UserCell.m
//  ProjectVoyage
//
//  Created by Gui David on 8/1/22.
//

#import "UserCell.h"
#import "Util.h"

@interface UserCell ()

@property (nonatomic, strong) IBOutlet UIImageView *userPictureImageView;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;

@end

@implementation UserCell

#pragma mark - Initialization

- (void)awakeFromNib {
    [super awakeFromNib];
    _nameLabel.text = _name;
    if (_userPicture) {
        [_userPictureImageView setImage:_userPicture];
    } else {
        [_userPictureImageView setImage:[UIImage imageNamed:@"user"]];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
 
