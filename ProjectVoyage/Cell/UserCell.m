//
//  UserCell.m
//  ProjectVoyage
//
//  Created by Gui David on 8/1/22.
//

#import "UserCell.h"
#import "Util.h"

@interface UserCell ()

@property (nonatomic, strong) IBOutlet UIImageView *userPicture;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;

@end

@implementation UserCell

#pragma mark - Initialization

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void) setUser:(PFUser *)user {
    UIImage *profilePicture = [UIImage imageWithData:[user[IMAGE] getData]];
    _nameLabel.text = user[NAME];
    if (profilePicture) {
        [_userPicture setImage:profilePicture];
    } else {
        [_userPicture setImage:[UIImage imageNamed:@"user.png"]];
    }
    [Util roundImage:_userPicture];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
 
