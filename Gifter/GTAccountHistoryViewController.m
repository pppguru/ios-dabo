//
//  GTAccountHistoryViewController.m
//  Gifter
//
//  Created by Karthik on 22/03/2015.
//
//

#import "GTAccountHistoryViewController.h"
#import "KTUtility.h"
#import "CartCell.h"

#import <UIImageView+AFNetworking.h>

@implementation GTAccountHistoryViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.navigationItem.title = NSLocalizedString(@"Account History", @"");
  [self.navigationItem
      setBackBarButtonItem:[[UIBarButtonItem alloc]
                               initWithTitle:@""
                                       style:UIBarButtonItemStyleDone
                                      target:nil
                                      action:nil]];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
  return (rand() % 20) + 1;
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return [CartCell getHight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSString *cellIdentifier = [CartCell cellIdentifier];

  CartCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (cell == nil) {
    cell = [[CartCell alloc] initWithStyle:UITableViewCellStyleDefault
                           reuseIdentifier:cellIdentifier];
  }

  NSInteger random = rand() % 8;

  NSArray *namesList = @[
    @"Adams",
    @"Mike",
    @"John",
    @"James",
    @"Jenny",
    @"Marco",
    @"Jake",
    @"Rahul"
  ];

  NSArray *imageList = @[
    @"https://d13yacurqjgara.cloudfront.net/users/35381/avatars/normal/"
    @"meg4.png?1401981546",
    @"https://d13yacurqjgara.cloudfront.net/users/37385/avatars/normal/"
    @"4cf6b32f6aa703b776287a15a2e045c9.jpeg?1407425989",
    @"https://d13yacurqjgara.cloudfront.net/users/13787/avatars/normal/"
    @"b71eb61a94c9cdf04dcc0e15b8c665d6.png?1420657303",
    @"https://d13yacurqjgara.cloudfront.net/users/24812/avatars/normal/"
    @"1_2.jpg?1359232983",
    @"https://d13yacurqjgara.cloudfront.net/users/61834/avatars/normal/"
    @"266472_2123376085642_3788254_o.jpg?1393971022",
    @"https://d13yacurqjgara.cloudfront.net/users/7288/avatars/normal/"
    @"muchmettwitter.jpg?1401803083",
    @"https://d13yacurqjgara.cloudfront.net/users/29678/avatars/normal/"
    @"9d783a27c901d84e3735d76da4e66b47.jpeg?1382978651",
    @"https://d13yacurqjgara.cloudfront.net/users/52084/avatars/normal/"
    @"ef07fd4b5e3d27774b8c077cc61d26d8.jpg?1411136929"
  ];

  cell.itemNameLbl.text = namesList[random];
  cell.priceLbl.text =
      [NSString stringWithFormat:@"Ordered %ld days ago.", (long)random];
  [cell.imageIconImageView
      setImageWithURL:[NSURL URLWithString:imageList[random]]];

  [cell.imageIconImageView setBackgroundColor:GT_RED];
  [[cell.imageIconImageView layer]
      setCornerRadius:cell.imageIconImageView.frame.size.width / 2];
  [[cell.imageIconImageView layer] setBorderWidth:1.0f];
  [[cell.imageIconImageView layer]
      setBorderColor:[UIColor colorWithRed:.98 green:.37 blue:.33 alpha:0.5]
                         .CGColor];

  return cell;
}
@end
