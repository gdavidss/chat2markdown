//
//  MarkdownExportVC.m
//  ProjectVoyage
//
//  Created by Gui David on 7/15/22.
//

#import "MarkdownExportVC.h"

@interface MarkdownExportVC ()
@property (weak, nonatomic) IBOutlet UIButton *mdCopyButton;
@property (weak, nonatomic) IBOutlet UITextView *textArea;

@end

@implementation MarkdownExportVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self convertToMarkdown];
}

- (void) convertToMarkdown {
    for (Message *message in self.messages) {
        NSLog(@"%@", message.text);
    }
    return;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
