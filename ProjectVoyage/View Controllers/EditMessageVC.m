//
//  EditMessageVC.m
//  ProjectVoyage
//
//  Created by Gui David on 7/12/22.
//

#import "EditMessageVC.h"

@interface EditMessageVC ()
@property (weak, nonatomic) IBOutlet UITextView *editView;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *restoreButton;

@end

@implementation EditMessageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _editView.text = _message.text;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)didPressRestore:(id)sender {
    _editView.text = _message.text;
}

@end
