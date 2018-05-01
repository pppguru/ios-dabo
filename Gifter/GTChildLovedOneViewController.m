//
//  GTChildLovedOneViewController.m
//  Gifter
//
//  Created by Karthik on 22/04/2015.
//
//

#import "GTChildLovedOneViewController.h"
#import "GTAPIClient.h"
#import "PeopleCell.h"
#import <UIImageView+AFNetworking.h>
#import "AddPersonViewController.h"
#import "GTGiftViewController.h"

@interface GTChildLovedOneViewController ()
@property(nonatomic, strong) NSArray *items;
@property(nonatomic, weak) IBOutlet UITableView *tableView;
@end

@implementation GTChildLovedOneViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.navigationItem.title = NSLocalizedString(@"Related Persons", @"");

  [self.navigationItem
      setBackBarButtonItem:[[UIBarButtonItem alloc]
                               initWithTitle:@""
                                       style:UIBarButtonItemStyleDone
                                      target:nil
                                      action:nil]];
    
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self loadContent];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)loadContent {
  //[MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    hud.labelText = @"Feels good to Dabo";
  [[GTAPIClient sharedInstance] getPeoplewithSuccess:^(id responseData) {
    if (responseData[@"data"] &&
        [responseData[@"data"] isKindOfClass:[NSArray class]]) {
      NSMutableArray *refined = [[NSMutableArray alloc] init];
      for (id item in responseData[@"data"]) {
        if ([item[@"parent_id"] integerValue] == [self.userId integerValue]) {
          [refined addObject:item];
        }
      }

      self.items = refined;
      [self.tableView reloadData];
    } else {
      self.items = nil;
    }
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view
                             animated:YES];
  } failure:^(NSError *er) {
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view
                             animated:YES];

  }];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
  return self.items.count;
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return [PeopleCell getHight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSString *cellIdentifier = [PeopleCell cellIdentifier];

  PeopleCell *cell =
      [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (cell == nil) {
    cell = [[PeopleCell alloc] initWithStyle:UITableViewCellStyleDefault
                             reuseIdentifier:cellIdentifier];
  }

  NSDictionary *item = self.items[indexPath.row];

  cell.nameLbl.text = item[@"first_name"];

  if (item[@"image"] != [NSNull null]) {
    [cell.profileImageView
        setImageWithURL:[NSURL URLWithString:item[@"image"]]];
  } else {
    [cell.profileImageView setImage:nil];
  }

  [cell.profileImageView setBackgroundColor:GT_RED];
  [[cell.profileImageView layer]
      setCornerRadius:cell.profileImageView.frame.size.width / 2];
  [[cell.profileImageView layer] setBorderWidth:1.0f];
  [[cell.profileImageView layer]
      setBorderColor:[UIColor colorWithRed:.98 green:.37 blue:.33 alpha:0.5]
                         .CGColor];

  return cell;
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  NSDictionary *item = self.items[indexPath.row];
  [self.parentView selectedRelative:item];
}

@end
