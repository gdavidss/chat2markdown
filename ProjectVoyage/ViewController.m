//
//  ViewController.m
//  ProjectVoyage
//
//  Created by Gui David on 7/19/22.
//

#import "ViewController.h"
@import MarkdownView;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    MarkdownView *md = [MarkdownView new];
    [self.view addSubview:md];
    md.frame = self.view.bounds;
    [md loadWithMarkdown:@"# Hello World!" enableImage:YES css:nil plugins:nil stylesheets:nil styled:YES];
}

/*
- (void)viewWillAppear:(BOOL)animated {
    MarkdownView *md = [MarkdownView new];
    
    [self.view addSubview:md];
    [md loadWithMarkdown:@"# Hello World!" enableImage:NO css:nil plugins:nil stylesheets:nil styled:NO];
    
}
 */


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
