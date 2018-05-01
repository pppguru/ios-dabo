//
//  GTCartViewController.m
//  Gifter
//
//  Created by Karthik on 22/03/2015.
//
//

#import "GTCartViewController.h"
#import "CartCell.h"
#import "KTUtility.h"
#import <QuartzCore/QuartzCore.h>
#import <UIImageView+AFNetworking.h>
#import "GTDeliveryViewController.h"

@implementation GTCartViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];

    self.navigationController.navigationBarHidden = NO;

    self.navigationItem.title = NSLocalizedString(@"Cart", @"");

    [self.navigationItem
      setBackBarButtonItem:[[UIBarButtonItem alloc]
                               initWithTitle:@""
                                       style:UIBarButtonItemStyleDone
                                      target:nil
                                      action:nil]];

    items = [[NSMutableArray alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(loadContent)
                                               name:@"CART_UPDATED"
                                             object:nil];
    
    //Tabel Cell Color Change
    [self.tableView setSeparatorColor:GT_LIGHT_DARK];
    
}

- (void)dealloc {
  UNREGISTER_ALL_NOTIFY(self);
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self setupUI];
  [self loadContent];
}
- (void)setupUI {
    [KTUtility setRoundedButtonUI:self.continueBtn];
//    [KTUtility setButtonUI:self.continueBtn];
}

- (IBAction)showDelivery:(id)sender {
    GTDeliveryViewController *delivery = (GTDeliveryViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"GTDeliveryViewController"];
    [self.navigationController pushViewController:delivery animated:YES];
 // [self performSegueWithIdentifier:@"SHOW_DELIVERY" sender:nil];
}

- (void)loadContent {
  [items removeAllObjects];
  [self.navigationController.tabBarItem setBadgeValue:nil];
  id cartItems = [[NSUserDefaults standardUserDefaults] objectForKey:@"CART"];
  if (cartItems) {
    [items addObjectsFromArray:cartItems];
    if ([cartItems count] > 0) {
      [self.navigationController.tabBarItem
          setBadgeValue:[NSString stringWithFormat:@"%ld", (unsigned long)[cartItems count]]];
    }
  }

  sortedItems = [[NSMutableDictionary alloc] init];
  itemCount = [[NSMutableDictionary alloc] init];
  for (id dict in items) {
    sortedItems[dict[@"id"]] = dict;
    id val = itemCount[dict[@"id"]];
    if (val) {
      NSUInteger value = [val integerValue];
      value++;
      itemCount[dict[@"id"]] = @(value);
    } else {
      itemCount[dict[@"id"]] = @(1);
    }
  }
  [self.tableView reloadData];
  [self calculate];
}

- (void)calculate {
    
  double totalCost = 0.0f;
    
  for (NSDictionary *item in items)
  {
      NSString *priceStr = item[@"price"];
      priceStr = [priceStr stringByReplacingOccurrencesOfString:@"$" withString:@""];
      
    double price = [priceStr floatValue];
    
    totalCost += price;
  }

    self.totalPriceLbl.text =
    [NSString stringWithFormat:@"$%0.2f", totalCost];
    
    self.taxPriceLbl.text = [NSString stringWithFormat:@"$15.00"];
    
    self.grandTotalLbl.text = [NSString stringWithFormat:@"$%0.2f", (totalCost + 15.00)];
    
    self.totalCountlbl.text = [[NSString alloc] initWithFormat:@"%ld", (long)[items count]];
    
    
//    self.totalPriceLbl.text =
//      [NSString stringWithFormat:@"$%0.2f", totalCost / 100.0f];
//  
//    self.taxPriceLbl.text = [NSString stringWithFormat:@"$%0.2f", 3000 / 100.0f];
//  
//    self.grandTotalLbl.text =
//      [NSString stringWithFormat:@"$%0.2f", (totalCost + 3000) / 100.0f];
    
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  if (!items.count) {
    tableView.tableFooterView.hidden = YES;
  } else {
    tableView.tableFooterView.hidden = NO;
  }
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
  return sortedItems.allKeys.count;
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return [CartCell getHight];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]){
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]){
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [CartCell cellIdentifier];

    CartCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
    cell = [[CartCell alloc] initWithStyle:UITableViewCellStyleDefault
                           reuseIdentifier:cellIdentifier];
    }

    NSDictionary *item = sortedItems[sortedItems.allKeys[indexPath.row]];

    [cell.imageIconImageView setBackgroundColor:[UIColor whiteColor]];

    [[cell.countLbl layer] setCornerRadius:12.50f];
    [cell.countLbl setClipsToBounds:YES];

    [[cell.countLbl layer] setBorderWidth:1.0f];
    [[cell.countLbl layer] setBorderColor:[UIColor whiteColor].CGColor];

//    [[cell.imageIconImageView layer] setBorderWidth:1.0f];
//    [[cell.imageIconImageView layer] setBorderColor:[GT_LIGHT_DARK CGColor]];
//    CALayer *rightBorder = [CALayer layer];
//    rightBorder.frame = CGRectMake(cell.imageIconImageView.frame.size.width - 1, 0, 0.5f, cell.imageIconImageView.frame.size.height);
//    rightBorder.backgroundColor = GT_LIGHT_DARK.CGColor;
//    [cell.imageIconImageView.layer addSublayer:rightBorder];

    
    cell.itemNameLbl.text = item[@"name"];
    if ([item[@"image"] isKindOfClass:[NSArray class]]) {
        NSArray *img = item[@"image"];
        if (img.count) {
          [cell.imageIconImageView
              setImageWithURL:[NSURL URLWithString:item[@"image"][0]]];
        }
    }
    else
    {
        [cell.imageIconImageView
         setImageWithURL:[NSURL URLWithString:item[@"image"]]];
    }
    
  //cell.priceLbl.text = [NSString
   //   stringWithFormat:@"$%0.2f", [item[@"price"] doubleValue] / 100.0f];
  
    cell.priceLbl.text = item[@"price"];
    
    NSNumber *val = itemCount[sortedItems.allKeys[indexPath.row]];
    if (val && [val integerValue] > 1) {
        cell.countLbl.hidden = NO;
        cell.countLbl.text = [[NSString alloc] initWithFormat:@"%02ld", (long)[val integerValue]];
    } else {
        cell.countLbl.hidden = YES;
    }

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView
    canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  // Return YES if you want the specified item to be editable.
  return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
     forRowAtIndexPath:(NSIndexPath *)indexPath {
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    NSDictionary *item = sortedItems[sortedItems.allKeys[indexPath.row]];
    [self removeItemWithId:item[@"id"]];
  }
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"Remove";
}

- (void)removeItemWithId:(NSString *)itemId {
  NSMutableArray *newItems = [[NSMutableArray alloc] init];
  for (id dict in items) {
    if (![[dict[@"id"] uppercaseString] isEqualToString:itemId]) {
      [newItems addObject:dict];
    }
  }

  [[NSUserDefaults standardUserDefaults] setObject:newItems forKey:@"CART"];
  [[NSUserDefaults standardUserDefaults] synchronize];
  [self loadContent];
}

@end
