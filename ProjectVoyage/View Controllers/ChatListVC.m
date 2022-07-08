//
//  ChatListVC.m
//  ProjectVoyage
//
//  Created by Gui David on 7/6/22.
//

#import "ChatListVC.h"
#import "Chat.h"
@interface ChatListVC ()

@end

@implementation ChatListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [Chat postChat:@"teste description" withRecipientName:@"rodolfo" withRecipientImage:[UIImage imageNamed:@"profile_tab.png"] withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if (error != nil) {
    NSLog(@"Error: %@", error.localizedDescription);
        } else {
            NSLog(@"Post made successfully");
        }
        // Hides progress HUD on completion
    }];
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
