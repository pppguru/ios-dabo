//
//  SecondViewController.m
//  Gifter
//
//  Created by Karthik on 21/03/2015.
//
//

#import "GTLovedOnesViewController.h"
#import "PeopleCell.h"
#import "GTAPIClient.h"
#import <UIImageView+AFNetworking.h>
#import <QuartzCore/QuartzCore.h>
#import "AddPersonViewController.h"

@interface GTLovedOnesViewController () {
  UISegmentedControl *segmentControl;
}
@property(nonatomic, weak) IBOutlet UITableView *tableView;
@property(nonatomic, strong) NSArray *items;
@property(nonatomic, strong) NSMutableArray *filteredItems;
@property(nonatomic,retain) UIRefreshControl *refreshControl;
@end

@implementation GTLovedOnesViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.navigationItem.title = NSLocalizedString(@"Loved Ones", @"");
  UIBarButtonItem *plusButton =
      [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"plus"]
                                       style:UIBarButtonItemStyleDone
                                      target:self
                                      action:@selector(plusAction:)];
  [self.navigationItem setRightBarButtonItem:plusButton];
  segmentControl = [[UISegmentedControl alloc]
      initWithItems:@[ @"Family", @"Friends", @"Work" ]];
  segmentControl.selectedSegmentIndex = 0;
  segmentControl.frame = CGRectMake(0, 0, 250, 29);
  [self.navigationItem setTitleView:segmentControl];
  [segmentControl setTintColor:GT_RED];
  [segmentControl addTarget:self
                     action:@selector(switchSegment:)
           forControlEvents:UIControlEventValueChanged];
  [self.navigationItem
      setBackBarButtonItem:[[UIBarButtonItem alloc]
                               initWithTitle:@""
                                       style:UIBarButtonItemStyleDone
                                      target:nil
                                      action:nil]];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshControlAction) forControlEvents:UIControlEventValueChanged];
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isLoginFirst:) name:@"isLogin" object:nil];
    
    [self.tableView addSubview:self.refreshControl];

    [self loadContent];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(afterlogOutLovedOne:) name:@"logoutLovedOne" object:nil];
}


-(void)afterlogOutLovedOne:(NSNotification*)notification{
     [self.navigationController popToRootViewControllerAnimated:NO];
     [self loadContent];
}


-(void)refreshControlAction{
    
    [self loadContent];
}

-(void)isLoginFirst :(NSNotification*)notification{
    
    [self loadContent];
    
}



- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isUpdated"]) {
        [self loadContent];
    }

  
}

- (void)plusAction:(id)sender {
  [self performSegueWithIdentifier:@"ADD_PERSON" sender:nil];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (IBAction)switchSegment:(UISegmentedControl *)typeSegment {
  if (self.filteredItems)
    [self.filteredItems removeAllObjects];
  else
    self.filteredItems = [[NSMutableArray alloc] init];

  for (NSDictionary *item in self.items) {
    if ([item[@"parent_id"] integerValue] == 0) {
      if (item[@"type"]) {
        NSInteger val = [item[@"type"] integerValue];
        if ((val - 1) == typeSegment.selectedSegmentIndex) {
          [self.filteredItems addObject:item];
        }
      } else {
        if (typeSegment.selectedSegmentIndex == 0) {
          [self.filteredItems addObject:item];
        }
      }
    }
  }

  [self.tableView reloadData];
}

- (void)loadContent {
  //[MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.labelText = @"Feels good to Dabo";
  [[GTAPIClient sharedInstance] getPeoplewithSuccess:^(id responseData) {
    if (responseData[@"data"] &&
        [responseData[@"data"] isKindOfClass:[NSArray class]]) {
      self.items = responseData[@"data"];

    } else {
      self.items = nil;
    }
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view
                             animated:YES];
      [self.refreshControl endRefreshing];
    [self switchSegment:segmentControl];
  } failure:^(NSError *er) {
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view
                             animated:YES];
      [self.refreshControl endRefreshing];
      self.filteredItems = nil;
      [self.tableView reloadData];
      if ([[GTAPIClient sharedInstance] isUserLoggedIn] == YES){
          UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Data Found"
                                                              message:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                                    otherButtonTitles:@"Retry", nil];
          [alertView show];
      }

  }];
    
}

- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex {
    
        switch (buttonIndex) {
            case 0:
                NSLog(@"%@", @"Button Cancel Pressed");
                break;
            case 1:
                NSLog(@"%@", @"Button Retry Pressed");
                [self loadContent];
                break;
                
            default:
                break;
        
    }
    
}


#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
  return self.filteredItems.count;
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

  NSDictionary *item = self.filteredItems[indexPath.row];

  cell.nameLbl.text = [NSString stringWithFormat:@"%@",item[@"first_name"]];

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
  NSDictionary *item = self.filteredItems[indexPath.row];
  [self performSegueWithIdentifier:@"ADD_PERSON" sender:item];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if (sender) {
    AddPersonViewController *destination = segue.destinationViewController;
    [destination loadEditMode:sender];
  } else {
    AddPersonViewController *destination = segue.destinationViewController;
    [destination setBaseSelectedType:segmentControl.selectedSegmentIndex];
  }
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
    NSDictionary *item = self.filteredItems[indexPath.row];
    [self deleteUser:[item[@"id"] integerValue]];
  }
}

- (void)deleteUser:(NSUInteger)item_id {
  id param = @{ @"friend_id" : @(item_id) };
  [[GTAPIClient sharedInstance] removeFriend:param
      withSuccess:^(id responseData) {
        [self loadContent];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isUpdated"];
      }
      failure:^(NSError *er){

      }];
}

@end
