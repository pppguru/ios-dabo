//
//  GTWebViewController.m
//  Gifter
//
//  Created by Muzammil Mohammad on 08/06/15.
//
//

#import "GTWebViewController.h"

@interface GTWebViewController () <UIWebViewDelegate>

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) UIActivityIndicatorView *indicatorView;

@end

@implementation GTWebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Amazon";
    
    self.webView.delegate = self;
    
    _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    
    [_indicatorView setTintColor:[UIColor redColor]];
    [_indicatorView setColor:[UIColor redColor]];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self loadWebView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
    [self.webView stopLoading];
    [self.webView setDelegate:nil];
}

- (void)loadWebView
{
    [_indicatorView startAnimating];
    
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:self.webURL]];
    
    [self.webView loadRequest:req];
}

- (void)showIndicator:(BOOL)show
{
    if (show) {
        
        [_indicatorView startAnimating];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_indicatorView];

    }
    else
    {
        [_indicatorView stopAnimating];
        
        self.navigationItem.rightBarButtonItem = nil;
    }
}

#pragma mark - Webview Delegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self showIndicator:YES];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self showIndicator:NO];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self showIndicator:NO];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
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
