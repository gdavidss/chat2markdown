//
//  EditMessageVC.m
//  ProjectVoyage
//
//  Created by Gui David on 7/12/22.
//

#import "EditMessageVC.h"

@interface EditMessageVC ()
@property (nonatomic, strong) IBOutlet UITextView *editView;
@property (nonatomic, strong) IBOutlet UIButton *editButton;
@property (nonatomic, strong) IBOutlet UIButton *restoreButton;

@end

@implementation EditMessageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _editView.text = _message.text;
}

- (IBAction)didPressEdit:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.message.text != self.editView.text) {
            self.message.text = self.editView.text;
            
            // Update array
            NSMutableArray<Message *> *chatMessages = self.delegate.chat.messages;
            NSInteger messageIndex = [chatMessages indexOfObject:self.message];
            chatMessages[messageIndex].text = self.editView.text;
            
            // Reload that specific row as opposed to all rows in table
            NSArray *indexPaths = [[NSArray alloc]
                                   initWithObjects:[NSIndexPath indexPathForRow:messageIndex inSection:0], nil];
            
            [self.delegate.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        }}];
}

- (IBAction)didPressRestore:(id)sender {
    _editView.text = _message.text;
}

@end
