//
//  FirstViewController.m
//  Gifter
//
//  Created by Karthik on 21/03/2015.
//
//

#import "GTExploreViewController.h"
#import "ProfileEditCell.h"
#import "KTUtility.h"
#import "GTAPIClient.h"
#import "UIControls+Blocks.h"
#import "GTGiftItemsViewController.h"
#import "GTRecommendedGiftVC.h"
#import "MDSGeocodingViewController.h"
#import "GTChildLovedOneViewController.h"
#import "UIAlertView+Blocks.h"
#import <UIImageView+AFNetworking.h>
#import "LaunchViewController.h"
#import "NSDictionary+Dabo.h"

@interface GTExploreViewController () {
}

@property(nonatomic, weak) IBOutlet UITableView *tableView;
@end

@implementation GTExploreViewController

- (void)viewDidLoad {
  [super viewDidLoad];
    
    
    self.navigationItem.title = NSLocalizedString(@"Explore", @"");
    self.navigationController.navigationBarHidden=NO;
    
  [self.navigationItem
      setBackBarButtonItem:[[UIBarButtonItem alloc]
                               initWithTitle:@""
                                       style:UIBarButtonItemStyleDone
                                      target:nil
                                      action:nil]];
    
    
    UIButton *searchButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 29., 25.)];
    [searchButton setImage:[UIImage imageNamed:@"icon-search"] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:searchButton];

    UIButton *refreshButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 23., 23.)];
    [refreshButton setImage:[UIImage imageNamed:@"icon-update"] forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:refreshButton];
    
}

- (void)dealloc {
    
  UNREGISTER_ALL_NOTIFY(self);
    
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden=NO;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
    
  return 10;
    
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
  return 263.;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdentifier = @"PROFILE_WISHLIST_CELL";
    
    UITableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier];
    }
    
    UIImageView *image = [cell.contentView viewWithTag:100];
    [image setImage:[UIImage imageNamed:[NSString stringWithFormat:@"sample_product_image%d", (int)indexPath.row % 4]]];
    
    
//    UIView *mainContentView = [cell.contentView viewWithTag:111];
//    [[mainContentView layer] setBorderWidth:0.3f];
//    [[mainContentView layer] setBorderColor:[UIColor lightTextColor].CGColor];
    
  return cell;
    
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
  }



@end
