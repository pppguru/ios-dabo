//
//  GTChildLovedOneViewController.m
//  Gifter
//
//  Created by Karthik on 22/04/2015.
//
//

#import "GTActivityViewController.h"
#import "GTAPIClient.h"
#import "PeopleCell.h"
#import <UIImageView+AFNetworking.h>
#import "AddPersonViewController.h"
#import "GTGiftViewController.h"

@interface GTActivityViewController ()
@property(nonatomic, strong) NSArray *items;
@property(nonatomic, weak) IBOutlet UITableView *tableView;
@end

@implementation GTActivityViewController

- (void)viewDidLoad {
  [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = NO;
    
    self.navigationItem.title = NSLocalizedString(@"Activity", @"");

    [self.navigationItem
      setBackBarButtonItem:[[UIBarButtonItem alloc]
                               initWithTitle:@""
                                       style:UIBarButtonItemStyleDone
                                      target:nil
                                      action:nil]];
    
    
    UIButton *settingButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 23., 23.)];
    [settingButton setImage:[UIImage imageNamed:@"icon-off-notifications"] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:settingButton];
    
    self.tableView.layer.borderWidth = 0.5f;
    self.tableView.layer.borderColor = GT_LIGHT_DARK.CGColor;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
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
  return 5;
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 86.;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"ACTIVITY_TABLE_CELL";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    UIImageView *imgView = [cell.contentView viewWithTag:100];
    [[imgView layer]
      setCornerRadius:imgView.frame.size.width / 2];
    [imgView setImage:[UIImage imageNamed:@"sample_photo"]];
    

  return cell;
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

@end
