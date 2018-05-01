//
//  FirstViewController.m
//  Gifter
//
//  Created by Karthik on 21/03/2015.
//
//

#import "GTGiftViewController.h"
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

@interface GTGiftViewController () {
  NSInteger currentSelectedIndex;
  NSMutableArray *subTitles;
  UIPickerView *pickerView;
  NSString *userId;
   BOOL isClicked;
   NSMutableArray *parentarray;
   
   NSMutableArray *boolArray;
   
   NSInteger minimumBudget;
   NSInteger maximumBudget;
   
   NSIndexPath *selectedIndex;
    
    UIDatePicker *datePicker;
    
}


@property (nonatomic) CGRect tableFrame;
@property(nonatomic, weak) IBOutlet UIButton *recommendationButton;
@property(nonatomic, weak) IBOutlet UITableView *tableView;
@property(nonatomic, weak) IBOutlet UISegmentedControl *segmentControl;
@property(nonatomic, weak) IBOutlet UISegmentedControl *categorySegmentControl;

@property(nonatomic, weak) IBOutlet UISearchBar *contentSearchBar;
@property(nonatomic, strong) NSArray *items;
@property(nonatomic, strong) NSArray *refinedItems;
@property (nonatomic,retain) IBOutlet UIView *segmentView;
@property(nonatomic,retain) UIRefreshControl *refreshControl;
@end

@implementation GTGiftViewController

- (void)viewDidLoad {
  [super viewDidLoad];
    
    self.navigationController.navigationBarHidden=NO;
    
    datePicker = [[UIDatePicker alloc] init];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableFrame = self.tableView.frame;
    minimumBudget = -1;
    maximumBudget = -1;
  currentSelectedIndex = 0;

  boolArray = [[NSMutableArray alloc]init];
    
  self.navigationItem.title = NSLocalizedString(@"Send a Gift to Someone", @"");
  [KTUtility setButtonUI:_recommendationButton];
  subTitles = [NSMutableArray arrayWithArray:@[ @"", @"", @"", @"", @"", @"",@"" ]];
  [self.navigationItem
      setBackBarButtonItem:[[UIBarButtonItem alloc]
                               initWithTitle:@""
                                       style:UIBarButtonItemStyleDone
                                      target:nil
                                      action:nil]];

  if ([[GTAPIClient sharedInstance] isUserLoggedIn] == NO) {
    [self performSelector:@selector(checkLoginAndPresentContainer)
               withObject:nil
               afterDelay:0.2];
  }

  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(checkLoginAndPresentContainer)
             name:@"/user/logout"
           object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isLoginFirst:) name:@"isLogin" object:nil];

     [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(clearSelection)
                                               name:@"CLEAR_CART"
                                             object:nil];

//    self.categorySegmentControl.frame = CGRectMake(0, 0, 250, 29);
//    [self.navigationItem setTitleView:self.categorySegmentControl];
    
    if ([[GTAPIClient sharedInstance] isUserLoggedIn] == YES){
        [self loadContent];
    }

    self.segmentControl.frame = CGRectMake(0, 0, 250, 29);
    [self.navigationItem setTitleView:self.segmentControl];
    
    [self.categorySegmentControl setSelectedSegmentIndex:0];
    [self categorySwitchSegment:self.categorySegmentControl];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshControlAction) forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl.bounds =CGRectMake(0, 30, 20, 20);
    [self.tableView addSubview:self.refreshControl];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(afterlogOutSetView:) name:@"logoutGiftView" object:nil];
    
}

- (BOOL)hidesBottomBarWhenPushed {
    return NO;
}



-(void)afterlogOutSetView:(NSNotification*)notification{
    
    [self.navigationController popToRootViewControllerAnimated:NO];
    [self loadContent];
}


-(void)isLoginFirst :(NSNotification*)notification{
    
    [self loadContent];
    
}

-(void)refreshControlAction{
    
    [self loadContent];
}


- (void)searchBar:(UISearchBar *)searchBar
    textDidChange:(NSString *)searchText {
    
  [self quickFilterContent];
  currentSelectedIndex = 0;
  [self.tableView reloadData];
    
}


- (void)dealloc {
    
  UNREGISTER_ALL_NOTIFY(self);
    
}


- (void)clearSelection {
    
  subTitles = [NSMutableArray arrayWithArray:@[ @"", @"", @"", @"", @"", @"",@"" ]];
  [[self tableView] reloadData];
    
}


- (void)loadContent
{
  //[MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    hud.labelText = @"Feels good to Dabo";
  [[GTAPIClient sharedInstance] getPeoplewithSuccess:^(id responseData) {
    if (responseData[@"data"] &&
        [responseData[@"data"] isKindOfClass:[NSArray class]]) {
      self.items = responseData[@"data"];
        
        for (int i = 0; i<[self.items count]; i++) {
          //  NSDictionary *dic = [self.items objectAtIndex:i];
           
        }

    } else
    {
      self.items = nil;
    }
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view
                             animated:YES];
    [self.refreshControl endRefreshing];
    [self quickFilterContent];
    [self.tableView reloadData];
  } failure:^(NSError *er) {
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view
                             animated:YES];
      [self.refreshControl endRefreshing];
      
      self.refinedItems=nil;
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
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isUpdated"];
    
}



- (void)quickFilterContent {
    //fdbdf
 
 NSMutableArray *array = [[NSMutableArray alloc] initWithArray:[self arrayAccordingToSegment]];
    
  if (self.contentSearchBar.text.length) {
    NSMutableArray *refinedArray = [[NSMutableArray alloc] init];
    for (id item in array) {
       NSString *firstNamestr = [NSString stringWithFormat:@"%@",item[@"first_name"]];
      if ([[firstNamestr uppercaseString]
              containsString:[self.contentSearchBar.text uppercaseString]] &&
          [item[@"parent_id"] integerValue] == 0) {
        [refinedArray addObject:item];
      }
    }

    self.refinedItems = [[NSMutableArray alloc] initWithArray:refinedArray];
  } else {
    NSMutableArray *refinedArray = [[NSMutableArray alloc] init];
    for (id item in array) {
     // if ([item[@"parent_id"] integerValue] == 0) {
        [refinedArray addObject:item];
     // }
    }
self.refinedItems = [[NSMutableArray alloc] initWithArray:refinedArray];
  }
}


- (IBAction)switchSegment:(id)sender {
    
  if (self.segmentControl.selectedSegmentIndex == 0) {
    [self.tableView addSubview:self.refreshControl];
    self.contentSearchBar.hidden = NO;
    self.categorySegmentControl.hidden = NO;
      
    CGRect frame = self.contentSearchBar.frame;
    frame.size.height = 44.0f;
    self.contentSearchBar.frame = frame;
      
    self.segmentView.hidden = NO;
      
    [self.tableView reloadData];

      
  } else {
      
    [self.refreshControl removeFromSuperview];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.contentSearchBar.hidden = YES;
    self.categorySegmentControl.hidden = YES;
    
    self.segmentView.hidden = YES;
    CGRect frame = self.contentSearchBar.frame;
    frame.size.height = 0.0f;
    self.contentSearchBar.frame = frame;
      [self.tableView reloadData];
  }
    
  [self.view endEditing:YES];
  [self.tableView reloadData];
    
}


-(NSMutableArray*)arrayAccordingToSegment{
    
    [boolArray removeAllObjects];
    
    int CategoryType = 0;
    switch (self.categorySegmentControl.selectedSegmentIndex) {
        case 0:
            CategoryType = 1;
            break;
            
        case 1:
            CategoryType = 2;
            break;
            
        case 2:
            CategoryType = 3;
            break;
            
        default:
            break;
    }
    //
    
    NSMutableArray *tempArray=[[NSMutableArray alloc]init];
    for (int i=0; i<[self.items count]; i++) {
        
        NSDictionary *parentDict=self.items[i];
        
        if ([[parentDict valueForKey:@"parent_id"] integerValue] == 0 ) {
            
            if ([[parentDict valueForKey:@"type"] integerValue] == CategoryType ) {
                [tempArray addObject:parentDict];
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                [dic setValue:[parentDict valueForKey:@"id"] forKey:@"parent_id"];
                [dic setValue:@NO forKey:@"IsChildOpen"];
                [boolArray addObject:dic];
                
            }
            
        }
    }
    
    
    parentarray = [[NSMutableArray alloc] init];
    
    for (int i=0; i<[self.items count]; i++) {
        
        NSDictionary *parentDict=self.items[i];
        
        if ([[parentDict valueForKey:@"parent_id"] integerValue] == 0 ) {
            
            [parentarray addObject:parentDict];
            
        }
        
    }
    
    NSMutableArray *mergedArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [parentarray count]; i++) {
        
        NSDictionary *indexDic = [parentarray objectAtIndex:i];
        [mergedArray addObject:indexDic];
        
    }
    
    NSLog(@"%lu",(unsigned long)self.items.count);
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i <self.items.count ; i++) {
        
        NSDictionary *item = self.items[i];
        if ([[item valueForKey:@"type"] integerValue] == CategoryType && [[item valueForKey:@"parent_id"] intValue] == 0) {
            [array addObject:item];
        }
    }
    
    return array;
    
}

- (IBAction)categorySwitchSegment:(id)sender {
  
    self.refinedItems = [[NSArray alloc] initWithArray:[self arrayAccordingToSegment]];
    
    [self.view endEditing:YES];
    self.contentSearchBar.text = nil;
    [self.tableView reloadData];
    
}


- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isUpdated"]) {
        [self loadContent];
    }
    
}

- (void)checkLoginAndPresentContainer {
    
  [self.navigationController.tabBarController
      performSegueWithIdentifier:@"LANDING_PAGE"
                          sender:nil];
  [self clearSelection];
    
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}


- (IBAction)openRecommended:(id)sender {
    
  if (self.segmentControl.selectedSegmentIndex == 0 &&
      self.refinedItems.count > 0) {
      
    [self performSegueWithIdentifier:@"OPEN_RECOMMENDED" sender:nil];
  } else if (self.segmentControl.selectedSegmentIndex == 1) {
      
      NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
      [defaults removeObjectForKey:@"LovedOneImage"];
      [defaults removeObjectForKey:@"Name"];
      
       NSString *forNewPerson =@"New Person";
      [[NSUserDefaults standardUserDefaults] setObject:forNewPerson forKey:@"NewPerson"];
      
      [self.view endEditing:YES];
      
      for (int i=0 ; i < 5; i++) {
          
      NSString *str = [subTitles objectAtIndex:i];
      if (str.length <= 0) {
        [[[UIAlertView alloc]
                initWithTitle:@""
                      message:
                          @"Please fill in all the details to suggest gifts."
                     delegate:nil
            cancelButtonTitle:@"OK"
            otherButtonTitles:nil] show];
        return;
      }
    }
      if (maximumBudget < 0 || minimumBudget < 0 || maximumBudget ==(int)nil || minimumBudget==(int)nil)
      {
          [[[UIAlertView alloc]
            initWithTitle:@""
            message:@"Plese enter minimum and maximum budget."
            delegate:nil
            cancelButtonTitle:@"OK"
            otherButtonTitles:nil] show];
          
          return;
      }
      
      if (maximumBudget < minimumBudget) {
          
          [[[UIAlertView alloc]
            initWithTitle:@""
            message:@"Maximum budget should be greater than minimum budget."
            delegate:nil
            cancelButtonTitle:@"OK"
            otherButtonTitles:nil] show];
          
          return;
      }
    [self performSegueWithIdentifier:@"OPEN_RECOMMENDED" sender:nil];
  }
}


#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
  if (self.segmentControl.selectedSegmentIndex == 0) {
    if (self.refinedItems.count) {
        
      self.recommendationButton.hidden = NO;
    } else {
      self.recommendationButton.hidden = YES;
    }
  } else {
    self.recommendationButton.hidden = NO;
  }

  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
  if (self.segmentControl.selectedSegmentIndex == 0) {
    return self.refinedItems.count;
  }
    
  return 6;
    
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
  return [ProfileEditCell getHight];
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSString *cellIdentifier;
    
    
    if (self.segmentControl.selectedSegmentIndex == 0) {
        
        NSDictionary *item = self.refinedItems[indexPath.row];
        
        if ([[item valueForKey:@"parent_id"] intValue] != 0) {
            
        cellIdentifier = @"PROFILE_CELLCHILD";
            
        }else{
            
        cellIdentifier = @"PROFILE_CELL";
            
        }
        
    } else {
        
        cellIdentifier = [ProfileEditCell cellIdentifier];
        if (indexPath.row == 5) {
            
            cellIdentifier = @"Budget_Cell";
            
        }
        
    }
    
    
  ProfileEditCell *cell =
      [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (cell == nil) {
    cell = [[ProfileEditCell alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:cellIdentifier];
  }
    
  if (self.segmentControl.selectedSegmentIndex == 1) {
//    NSArray *titles = @[
//      @"Age",
//      @"Relation",
//      @"Lives In",
//      @"Likes",
//      @"Occassion",
//      @"Date",
//      @"Gift Budget"
//    ];
      
      NSArray *titles = @[
                          @"Age",
                          @"Relation",
                          @"Lives In",
                          @"Likes",
                          @"Occassion",
                          @"Gift Budget"
                          ];
      
//    NSArray *images =
//        @[ @"birthday", @"conn", @"locationPin", @"heart", @"cal",@"cal", @"wallet" ];
    NSArray *images =
      @[ @"birthday", @"conn", @"locationPin", @"heart", @"cal", @"wallet" ];
      
    cell.nameLbl.text = titles[indexPath.row];
    cell.selectionLbl.text = subTitles[indexPath.row];
    cell.typeImageView.image = [[UIImage imageNamed:images[indexPath.row]]
        imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [cell.typeImageView setTintColor:GT_RED];
      
      if (indexPath.row == 5) {
          cell.selectionStyle = UITableViewCellSelectionStyleNone;
          cell.maxBudget = subTitles[indexPath.row];
          cell.minBudget = subTitles[indexPath.row];
      }

  } else {
      //
      
    NSDictionary *item = self.refinedItems[indexPath.row];
      
    cell.nameLbl.text = [NSString stringWithFormat:@"%@",item[@"first_name"]];
    cell.selectionLbl.text = [NSString
        stringWithFormat:@"%@, %@ - ", item[@"relation"],
                         item[@"lives_in"]];

    if (item[@"image"] != [NSNull null]) {
      [cell.typeImageView setImageWithURL:[NSURL URLWithString:item[@"image"]]];
    } else {
      [cell.typeImageView setImage:nil];
    }

    [cell.typeImageView setBackgroundColor:GT_RED];
    [[cell.typeImageView layer]
        setCornerRadius:cell.typeImageView.frame.size.width / 2];
    [[cell.typeImageView layer] setBorderWidth:1.0f];
    [[cell.typeImageView layer]
        setBorderColor:[UIColor colorWithRed:.98 green:.37 blue:.33 alpha:0.5]
                           .CGColor];

    if (currentSelectedIndex == indexPath.row) {
      cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
      cell.accessoryType = UITableViewCellAccessoryNone;
    }
  }
    
  return cell;
    
}


- (BOOL)checkIfHasChild:(NSUInteger)parentId {
    
  NSDictionary *item = self.refinedItems[parentId];
  NSString *currentUserId = item[@"id"];
  NSMutableArray *refined = [[NSMutableArray alloc] init];
    
  NSMutableArray *array = [self.items mutableCopy];
    
  for (id itm in array) {
    if ([itm[@"parent_id"] integerValue] == [currentUserId integerValue]) {
      [refined addObject:item];
    }
      
  }

  if (refined.count) {
    return YES;
  } else {
    return NO;
  }
}

-(void)insertChildInArray:(NSIndexPath*)selectedIndexPath withParentId:(NSString*)parentId
{
    NSMutableArray *refinedDemoArray = [[NSMutableArray alloc] initWithArray:self.refinedItems];
    
    for (int j = 0; j < [boolArray count]; j++) {
        
        NSDictionary *dic = [boolArray objectAtIndex:j];
        
        if ([[dic valueForKey:@"parent_id"] intValue] == [parentId intValue]) {
            
            if (![[dic valueForKey:@"IsChildOpen"]boolValue]) {
                
                if ([[dic valueForKey:@"parent_id"] intValue] == [parentId intValue]) {
                    
                    for (int j = 0; j < [self.items count]; j++) {
                        
                        NSDictionary *childDic = [self.items objectAtIndex:j];
                        if ([[childDic valueForKey:@"parent_id"] intValue] == [parentId intValue]) {
                            [refinedDemoArray insertObject:childDic atIndex:selectedIndexPath.row+1];
                        }
                    }
                    
                    [dic setValue:@YES forKey:@"IsChildOpen"];
                    [boolArray replaceObjectAtIndex:j withObject:dic];
                    
                    break;
                }
            }
            else{
                NSMutableArray *array = [[NSMutableArray alloc] init];
                
                for (int j = 0; j < [refinedDemoArray count]; j++) {
                    
                    NSDictionary *childDic = [refinedDemoArray objectAtIndex:j];
                    if ([[childDic valueForKey:@"parent_id"] intValue] != [parentId intValue]) {
                        [array addObject:childDic];
                    }
                }
                refinedDemoArray = [array mutableCopy];
                [dic setValue:@NO forKey:@"IsChildOpen"];
                [boolArray replaceObjectAtIndex:j withObject:dic];
                break;
            }
        }
    }
   self.refinedItems = [refinedDemoArray mutableCopy];
   //[self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    selectedIndex = indexPath;
    [self.view endEditing:YES];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  if (self.segmentControl.selectedSegmentIndex == 0) {
    if ([self checkIfHasChild:indexPath.row]) {
        
        NSDictionary *item = self.refinedItems[indexPath.row];
        
        userId = item[@"id"];
        currentSelectedIndex = indexPath.row;
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        NSString *valueToSave = [item valueForKey:@"image"];
        NSString *v2=[NSString stringWithFormat:@"%@",[item valueForKey:@"first_name"]];
        [[NSUserDefaults standardUserDefaults] setObject:valueToSave forKey:@"LovedOneImage"];
        [[NSUserDefaults standardUserDefaults] setObject:v2 forKey:@"Name"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self insertChildInArray:indexPath withParentId:[item objectForKey:@"id"]];
        
        NSRange range = NSMakeRange(0, tableView.numberOfSections);
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
        [tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
         //[tableView reloadData];
        
    } else
    {
      NSDictionary *item = self.refinedItems[indexPath.row];
        
      userId = item[@"id"];
      currentSelectedIndex = indexPath.row;
      [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        NSString *valueToSave = [item valueForKey:@"image"];
        NSString *v2=[NSString stringWithFormat:@"%@",[item valueForKey:@"first_name"]];
        [[NSUserDefaults standardUserDefaults] setObject:valueToSave forKey:@"LovedOneImage"];
        [[NSUserDefaults standardUserDefaults] setObject:v2 forKey:@"Name"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
      [tableView reloadData];
    }
      
  }
  else
  {
    [self.view endEditing:YES];
      
      NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
      [defaults removeObjectForKey:@"LovedOneImage"];
    if (indexPath.row == 2) {
      MDSGeocodingViewController *geoCoding =
          [[MDSGeocodingViewController alloc]
              initWithNibName:@"MDSGeocodingViewController"
                       bundle:nil];
      [geoCoding setDelegate:(id<MDSGeoCodingDelegate>)self];
      [self.navigationController pushViewController:geoCoding animated:YES];
      return;
    } else if (indexPath.row == 3) {
      UIAlertView *alert = [[UIAlertView alloc]
              initWithTitle:nil
                    message:NSLocalizedString(
                                @"Enter the likes seperated by comma", @"")
                   delegate:self
          cancelButtonTitle:@"Cancel"
          otherButtonTitles:NSLocalizedString(@"OK", @""), nil];
        
      [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        UITextField *textField = [alert textFieldAtIndex:0];
        textField.placeholder = @"e.g. Levis, Cell phones, Books, Shoes";
      [alert setDelegate:self];
      [[alert textFieldAtIndex:0] setDelegate:(id<UITextFieldDelegate>)self];
      [alert setTag:102];
      [alert show];
      return;
    }
      
    else if (indexPath.row == 5)
    {
        
        return ;
    }
      
//    else if (indexPath.row == 5) {
//        
//        [datePicker setDate:[NSDate date]];
//        datePicker.datePickerMode = UIDatePickerModeDate;
//        [datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
//        datePicker.frame = CGRectMake(0, 40, self.view.frame.size.width, 200);
//        UIView *view = [[UIView alloc]
//                        initWithFrame:CGRectMake(0, self.view.frame.size.height - 220,
//                                                 self.view.frame.size.width, 240)];
//        view.tag = 1001;
//        view.backgroundColor = [UIColor whiteColor];
//        [self addToolbar:view];
//        [view addSubview:datePicker];
//        [self.view addSubview:view];
//        return;
//        
//        ///[txtFieldBranchYear setInputView:datePicker];
//    }
      
    pickerView = [self makeAPicker:indexPath.row];

    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - 270,
                                 self.view.frame.size.width, 240)];
    view.tag = 1001;
    [self addToolbar:view];
    [view addSubview:pickerView];
    [self.view addSubview:view];

    NSMutableArray *items = nil;
    if (indexPath.row == 0) {
      items = [[NSMutableArray alloc] init];

      for (int i = 1; i <= 60; i++) {
        [items addObject:[NSString stringWithFormat:@"%d Years", i]];
      }
    } else if (indexPath.row == 1) {
      items = [[NSMutableArray alloc] initWithArray:[@[
        @"Friend",
        @"Wife",
        @"Mother",
        @"Father",
        @"Sister",
        @"Brother",
        @"Son",
        @"Daughter"
      ] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    } else if (indexPath.row == 4) {
    [self updateTableViewFrame:200];
      items = [[NSMutableArray alloc]
          initWithArray:[@[ @"Birthday", @"Anniversary", @"Valentine's Day",@"graduation",@"wedding",@"bridal shower",@"engagement",@"special occasion",@"In Dabo mood", ]
                            sortedArrayUsingSelector:
                                @selector(localizedCaseInsensitiveCompare:)]];
    }
    
      
      
    [pickerView setTitles:@[ items ]];

    [pickerView
        handleSelectionWithBlock:^void(UIPickerView *pickerView, NSInteger row,
                                       NSInteger component) {
          [subTitles replaceObjectAtIndex:indexPath.row withObject:items[row]];
          [tableView reloadData];
        }];

    if ([subTitles[indexPath.row] length] <= 0) {
      [subTitles replaceObjectAtIndex:indexPath.row withObject:items[0]];
      [tableView reloadData];
    }
  }
}


- (void)dateChanged:(id)sender{
    
    NSIndexPath *indexpath=selectedIndex;
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"M-d-yyyy"];
    
    subTitles[indexpath.row] = [NSString stringWithFormat:@"%@",
                                [df stringFromDate:datePicker.date]];
    
    NSLog(@"%@",[NSString stringWithFormat:@"%@",
                 [df stringFromDate:datePicker.date]]);
    
    [self.tableView reloadData];
}


- (UIPickerView *)makeAPicker:(NSUInteger)row {
  UIPickerView *myPickerView = [[UIPickerView alloc]
      initWithFrame:CGRectMake(0, 40, self.view.frame.size.width, 200)];
  myPickerView.backgroundColor = [UIColor whiteColor];
  myPickerView.showsSelectionIndicator = YES;
  myPickerView.tag = row;

  return myPickerView;
}

- (void)addToolbar:(UIView *)view {
  UIToolbar *doneToolbar = [[UIToolbar alloc]
      initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
  doneToolbar.barStyle = UIBarStyleDefault;

  UIBarButtonItem *selectBtn =
      [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil)
                                       style:UIBarButtonItemStyleDone
                                      target:self
                                      action:@selector(selectBtn:)];

  [selectBtn setTintColor:GT_LIGHT_RED];
  [selectBtn setTitleTextAttributes:@{
    NSFontAttributeName : SKIA_REGULAR(16),
    NSForegroundColorAttributeName : GT_RED
  } forState:UIControlStateNormal];
  [selectBtn setTintColor:GT_RED];
    
    UIBarButtonItem *cancelButton =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Clear", @"Clear")
                                     style:UIBarButtonItemStyleDone
                                    target:self
                                    action:@selector(cancelButton:)];
    
    
    [cancelButton setTitleTextAttributes:@{
                                           NSFontAttributeName : SKIA_REGULAR(16),
                                           NSForegroundColorAttributeName : GT_RED
                                           } forState:UIControlStateNormal];
    
    [cancelButton setTintColor:GT_RED];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
  //doneToolbar.items = @[ selectBtn ];
doneToolbar.items = @[cancelButton, flexibleSpace, selectBtn ];
  [doneToolbar sizeToFit];
  [view addSubview:doneToolbar];
}

- (void)cancelButton:(id)sender
{
    [subTitles replaceObjectAtIndex:selectedIndex.row withObject:@""];
    
    [[self.view viewWithTag:1001] removeFromSuperview];
    [[self.view viewWithTag:1002] removeFromSuperview];
    [self.tableView reloadData];
    
    [self updateTableViewFrame:0];
    
}


- (void)selectBtn:(id)sender {
  [[self.view viewWithTag:1001] removeFromSuperview];
  
}

- (void)closeKeyboard:(id)sender {
  [[self.view viewWithTag:1001] removeFromSuperview];
  [pickerView setHidden:YES];
}

- (void)alertView:(UIAlertView *)alertView
    clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag==102 ||alertView.tag ==101) {
        NSLog(@"");
    }
    
    else {
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
    
  NSString *inputText = [[alertView textFieldAtIndex:0] text];

  if (buttonIndex == 1) {
    if (alertView.tag == 101) {
      [subTitles replaceObjectAtIndex:2 withObject:inputText];
    } else if (alertView.tag == 102) {
      [subTitles replaceObjectAtIndex:3 withObject:inputText];
    }
  }
    
  [self.tableView reloadData];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  GTGiftItemsViewController *destination = segue.destinationViewController;
  if (self.segmentControl.selectedSegmentIndex == 0 &&
      currentSelectedIndex >= 0) {
    NSDictionary *item = self.refinedItems[currentSelectedIndex];
    destination.params = @{ @"friend_id" : item[@"id"] };
  } else {
    NSArray *titles = @[
      @"Age",
      @"Relation",
      @"Lives In",
      @"Likes",
      @"Occassion",
      @"minimum",
      @"maximum"
    ];
      
      
    NSMutableDictionary *param =
        [[NSMutableDictionary alloc] initWithObjects:subTitles forKeys:titles];
      [param setObject:[NSString stringWithFormat:@"%ld", (long)maximumBudget] forKey:@"maximum"];
      [param setObject:[NSString stringWithFormat:@"%ld", (long)minimumBudget] forKey:@"minimum"];
      
    destination.params = param;
  }
}

- (void)selectedLocation:(NSString *)locationInformation
         withCoordinates:(CLLocationCoordinate2D)coordinate {
  [subTitles replaceObjectAtIndex:2 withObject:locationInformation];
  [self.tableView reloadData];
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)dismiss {
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
  [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self quickFilterContent];
    [self.tableView reloadData];
    [searchBar setShowsCancelButton:NO animated:YES];
    searchBar.text = @"";
    [searchBar resignFirstResponder];
}

- (void)selectedRelative:(id)userInfo {
  [self.navigationController popViewControllerAnimated:NO];
  UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
  GTGiftItemsViewController *vc = (GTGiftItemsViewController *)
      [sb instantiateViewControllerWithIdentifier:@"RECOMMENDED_LIST"];
  vc.params = @{ @"friend_id" : userInfo[@"id"] };
  [self.navigationController pushViewController:vc animated:YES];
}


- (void)updateBackgroundViewFrame:(NSInteger)y
{
    [UIView animateWithDuration:0.25 animations:^{
        
        CGRect frame        = self.view.frame;
        frame.origin.y      = y;
        self.view.frame     = frame;
        
        [self.view setNeedsLayout];
        //[self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x, 0, self.tableView.frame.size.width, self.tableView.frame.size.height)];
    }];
    
   // NSLog(@"Table - %f",self.tableView.frame.origin.y);
   // NSLog(@"View - %f",self.view.frame.origin.y);
}

- (void)updateTableViewFrame:(NSInteger)y
{
    //[UIView animateWithDuration:0.25 animations:^{
    [self.tableView setContentOffset:CGPointMake(0, y) animated:YES];
    
     //[self.tableView scrollRectToVisible:CGRectMake(0, y, self.view.frame.size.height, self.view.frame.size.width) animated:YES];
    //}];
}


#pragma mark - UITextField Delegate


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.tag == 301 || textField.tag == 302) // For min and max budget
    {
        [self updateBackgroundViewFrame:-110];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
    [self updateBackgroundViewFrame:0];
    
    if (textField.tag == 301) {
        
        minimumBudget = [[textField text] integerValue];
    }
    
    if (textField.tag == 302) {
        
        maximumBudget = [[textField text] integerValue];
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqual:@"\n"]) {
        
        [textField resignFirstResponder];
        
        [self updateBackgroundViewFrame:0];
        
        return NO;
    }
    
    return YES;
}





@end
