//
//  LaunchViewController.m
//  Gifter
//
//  Created by Macwaves on 10/30/15.
//
//

#import "LaunchViewController.h"
#import "UIImage+animatedGIF.h"
#import "GTGiftViewController.h"
#import "GTBaseTabBarViewController.h"

@interface LaunchViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *animatedImageView;

@end

@implementation LaunchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
     self.navigationController.navigationBarHidden=YES;
    
    NSString *deviceType = [UIDevice currentDevice].model;
    
    if([deviceType isEqualToString:@"iPod touch"])
    {
        self.animatedImageView.image = [UIImage imageNamed:@""];
        [self back];
    }
    else
    {
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"Dabo" withExtension:@"gif"];
    UIImage *testImage = [UIImage animatedImageWithAnimatedGIFData:[NSData dataWithContentsOfURL:url]];
    self.animatedImageView.animationImages = testImage.images;
    self.animatedImageView.animationDuration = 3.0f;
    self.animatedImageView.animationRepeatCount = 1;
    self.animatedImageView.image = testImage.images.lastObject;
    [self.animatedImageView startAnimating];
 
    [self performSelector:@selector(back) withObject:nil afterDelay:5.0];
    }
    // Do any additional setup after loading the view.
}

- (BOOL)hidesBottomBarWhenPushed {
    return YES;
}

- (void)back
{
    [self.navigationController popToRootViewControllerAnimated:NO];
    
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
