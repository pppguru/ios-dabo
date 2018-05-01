//
//  PrivacyPolicyViewController.m
//  Gifter
//
//  Created by Ajeet on 9/28/15.
//
//

#import "PrivacyPolicyViewController.h"
#import "AppDelegate.h"

@interface PrivacyPolicyViewController ()<UIWebViewDelegate>
@property (nonatomic,retain) IBOutlet UIWebView *policyView;
@end

@implementation PrivacyPolicyViewController
@synthesize navTitle,docFileName;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = self.navTitle;
    
    [self.policyView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:docFileName ofType:@"html"]isDirectory:NO]]];
    [self.policyView setUserInteractionEnabled:YES];
    [self.policyView setScalesPageToFit:YES];
    [self.policyView.scrollView setShowsHorizontalScrollIndicator:NO];
    [self.policyView.scrollView setShowsVerticalScrollIndicator:NO];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
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
