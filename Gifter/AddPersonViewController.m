//
//  AddPersonViewController.m
//  Gifter
//
//  Created by Karthik on 22/03/2015.
//
//

#define kParam_age              @"age"
#define kParam_anniversary      @"anniversary"
#define kParam_birthday         @"birthday"
#define kParam_budget           @"budget"
#define kParam_dated            @"dated"
#define kParam_first_name       @"first_name"
#define kParam_id               @"id"
#define kParam_image            @"image"
#define kParam_likes            @"likes"
#define kParam_lives_in         @"lives_in"
#define kParam_maximum          @"maximum"
#define kParam_minimum          @"minimum"
#define kParam_parent_id        @"parent_id"
#define kParam_relation         @"relation"
#define kParam_type             @"type"
#define kParam_occasion_json    @"occasion_json"

#define budgetCellIndex         3

#import "AddPersonViewController.h"
#import <UIImageView+AFNetworking.h>
#import <FDTakeController.h>
#import <QuartzCore/QuartzCore.h>
#import "MDSGeocodingViewController.h"
#import "GTChildLovedOneViewController.h"
#import "GTGiftItemsViewController.h"

#import "UIControls+Blocks.h"
#import "ProfileEditCell.h"
#import "KTUtility.h"
#import "GTAPIClient.h"
#import "AddMoreOccasionsVC.h"
#import "AppDelegate.h"
#import "JSON.h"

@interface AddPersonViewController () <UITextFieldDelegate>
{
    FDTakeController *takeController;
   // NSMutableArray *subTitles;
    UIPickerView *pickerView;
    NSMutableDictionary *userDetails;
    NSArray *serverKeys;
    
    IBOutlet UIScrollView *scrollView;
    IBOutlet NSLayoutConstraint *scrollViewHeigh;
    
    IBOutlet UIView *lovedOneLblView;
    IBOutlet UIView *bottomView;
    
    IBOutlet UIImageView *lovedOneImageView;
    
    NSInteger minimumBudget;
    NSInteger maximumBudget;
    
    BOOL loadContent;
    
    UIDatePicker *datePicker;
    ProfileEditCell *label;
    NSIndexPath *selectedIndex;
    NSArray *titles;
    
    AppDelegate *delegate;
    
    IBOutlet UIButton *addOccationsBtn;
    
    //UITextField *selectedTF;
    
    ProfileEditCell *cell;
}

@property(nonatomic, retain) NSString *userId;
@property(nonatomic, assign) NSUInteger type;

@property(nonatomic, weak) IBOutlet UITableView *tableView;
@property(nonatomic, weak) IBOutlet UIButton *saveButton;
@property(nonatomic, weak) IBOutlet UIImageView *profileImageView;
@property(nonatomic, weak) IBOutlet UITextField *nameLbl;
@property(nonatomic, weak) IBOutlet UISegmentedControl *personType;
@property (nonatomic, strong) NSMutableArray *occasionArr;

@property(nonatomic, strong) NSArray *items;
@end

@implementation AddPersonViewController


#pragma mark - viewDidLoad
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.saveButton.hidden=YES;

    minimumBudget = -1;
    maximumBudget = -1;
    
    //selectedTF = [[UITextField alloc]init];
    //selectedTF.delegate=self;
    
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveButton:)];
    
    self.navigationItem.rightBarButtonItem = saveButton;
    
    [self.personType setTintColor:GT_RED];
    
    self.navigationItem.title = NSLocalizedString(@"Edit Person", @"");
    if (self.userId) {
        
        [self handleUIForScroll];
        
        if (!(userDetails==0||userDetails==nil)) {
            
            self.saveButton.hidden=NO;
                    [self.navigationItem
                     setRightBarButtonItem:[[UIBarButtonItem alloc]
                                            initWithTitle:@"Delete"
                                            style:UIBarButtonItemStyleDone
                                            target:self
                                            action:@selector(
                                                             deleteCurrentRecord)]];

        }
        
        
    } else {
        if (!userDetails) {
            [self.personType setSelectedSegmentIndex:self.baseSelectedType];
            [self handleUIForScroll];
        } else {
            loadContent = YES;
        }
    }
    
    if (!userDetails) {
        self.navigationItem.title = NSLocalizedString(@"Add Person", @"");
        userDetails = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"",kParam_relation,@"",kParam_lives_in,@"",kParam_likes,@"",kParam_birthday,@"",kParam_anniversary,@"",kParam_budget,@"",kParam_id,@"",kParam_first_name,@"",kParam_age, nil];
       // subTitles = [NSMutableArray arrayWithArray:@[ @"", @"", @"",@"",@"",@"",@"" ]];
        
    } else {
    
        UIImageView *imgView=[[UIImageView alloc]init];
        imgView.image=[UIImage imageNamed:@"NavArrow"];
        UIBarButtonItem *backButton=[[UIBarButtonItem alloc] initWithImage:imgView.image style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
        self.navigationItem.leftBarButtonItem = backButton;
        
        [saveButton setTitle:@"Save"];
        self.nameLbl.text = userDetails[kParam_first_name];
        NSInteger val = [userDetails[kParam_type] integerValue];
        [self.personType setSelectedSegmentIndex:val - 1];
        [self.profileImageView
         setImageWithURL:[NSURL URLWithString:userDetails[kParam_image]]];
        [self.tableView reloadData];
    }
    
    [KTUtility setButtonUI:self.saveButton];
    takeController = [[FDTakeController alloc] init];
    [takeController setDelegate:(id<FDTakeDelegate>)self];
    
    [self.navigationItem
     setBackBarButtonItem:[[UIBarButtonItem alloc]
                           initWithTitle:@""
                           style:UIBarButtonItemStyleDone
                           target:nil
                           action:nil]];
    
    [[self.profileImageView layer]
     setCornerRadius:self.profileImageView.frame.size.width / 2];
    [[self.profileImageView layer] setBorderWidth:1.0f];
    [[self.profileImageView layer]
     setBorderColor:[UIColor colorWithRed:.98 green:.37 blue:.33 alpha:0.5]
     .CGColor];
    
    [lovedOneImageView
     setImage:[[UIImage imageNamed:@"heart"]
               imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    
    titles = @[@"Relation", @"Lives In", @"Likes",@"Gift budget"];
    serverKeys =  @[kParam_relation, kParam_lives_in, kParam_likes,kParam_budget,kParam_birthday,kParam_anniversary];
    self.occasionArr = [[NSMutableArray alloc] init];
    
    delegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    delegate.occasionJsonStr = @"";
    
    if (loadContent)
    {
        [self loadContent];
    }
    else
    {
        [self refreshOccasion];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
     [self refreshOccasion];
}

- (void)refreshOccasion
{
    delegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    if (delegate.occasionJsonStr!=nil)
    {
        NSError *jsonError;
        NSData *objectData = [delegate.occasionJsonStr dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:objectData
                                                           options:NSJSONReadingMutableContainers
                                                             error:&jsonError];
        
        self.occasionArr = [jsonArr mutableCopy];
        
        if (self.occasionArr.count>0) {
            
            [addOccationsBtn setTitle:@"Add More Occasions" forState:UIControlStateNormal];
        }
        else
        {
            [addOccationsBtn setTitle:@"Add Occasion" forState:UIControlStateNormal];
        }
    }
    else
    {
        [addOccationsBtn setTitle:@"Add Occasion" forState:UIControlStateNormal];
    }
    [self.tableView reloadData];
}

#pragma mark - Suggest Gifts

-(IBAction)suggestGift:(id)sender{
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"LovedOneImage"];
    [defaults removeObjectForKey:@"Name"];
    
    for (int i=0 ; i<6; i++) {
        
     //  NSString *str = [subTitles objectAtIndex:i];
        NSString *str = [userDetails valueForKey:[serverKeys objectAtIndex:i]];
        NSString *title = [titles objectAtIndex:i];
        
        if (str.length <= 0 || self.nameLbl.text.length <= 0)
        {
            if ([title isEqualToString:@"Occasion"])   /// checking anniversary value becoz its optional
            {
                continue;
            }
            
            [[[UIAlertView alloc]
              initWithTitle:@""
              message:@"Please fill in all the details to suggest gifts."
              delegate:nil
              cancelButtonTitle:@"OK"
              otherButtonTitles:nil] show];
                return;
            }
        }
    
    NSString *valueToSave = [userDetails valueForKey:kParam_image];
    NSString *valueToSave2 = [userDetails valueForKey:kParam_first_name];
    [[NSUserDefaults standardUserDefaults] setObject:valueToSave forKey:@"LovedOneImage"];
    [[NSUserDefaults standardUserDefaults] setObject:valueToSave2 forKey:@"Name"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    GTGiftItemsViewController *gtGift = (GTGiftItemsViewController*)[mainStoryboard
                                                    instantiateViewControllerWithIdentifier: @"RECOMMENDED_LIST"];
    
    [self.navigationController pushViewController:gtGift animated:YES];
    
}

- (void)deleteCurrentRecord
{
  [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
  NSUInteger item_id = [userDetails[kParam_id] integerValue];
  id param = @{ @"friend_id" : @(item_id) };
  [[GTAPIClient sharedInstance] removeFriend:param
      withSuccess:^(id responseData) {
        [self.navigationController popViewControllerAnimated:YES];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isUpdated"];
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view
                                 animated:YES];
      }
      failure:^(NSError *er) {
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view
                                 animated:YES];

      }];
}


- (void)handleUIForScroll {
  self.personType.hidden = YES;
  scrollViewHeigh.constant = 0.0f;
  scrollView.hidden = YES;
  lovedOneLblView.hidden = YES;
  CGRect frame = self.tableView.tableHeaderView.frame;
  frame.size.height = frame.size.height - 60;
  [self.tableView.tableHeaderView setFrame:frame];
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
        if ([item[kParam_parent_id] integerValue] ==
            [userDetails[kParam_id] integerValue]) {
          [refined addObject:item];
        }
      }
        
        delegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
        
        delegate.occasionJsonStr = [userDetails valueForKey:kParam_occasion_json];
        
        
        
        if (delegate.occasionJsonStr!=nil) {
            NSError *jsonError;
            NSData *objectData = [delegate.occasionJsonStr dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:objectData
                                                               options:NSJSONReadingMutableContainers
                                                                 error:&jsonError];
            
            if (jsonArr!=nil)
            {
                self.occasionArr = [jsonArr mutableCopy];
                if (jsonArr.count>0)
                {
                     [addOccationsBtn setTitle:@"Add More Occasions" forState:UIControlStateNormal];
                }
                else
                {
                     [addOccationsBtn setTitle:@"Add Occasion" forState:UIControlStateNormal];
                }
            }
        }
        else
        {
            [addOccationsBtn setTitle:@"Add Occasion" forState:UIControlStateNormal];
        }
        
      self.items = refined;
      [self generateScrollView];
        
        if (self.occasionArr == nil) {
            self.occasionArr = [[NSMutableArray alloc]init];
        }
        
        if (self.occasionArr.count>0) {
            NSString *occasionStr = [userDetails objectForKey:kParam_birthday];
            NSString *occasionDate = [userDetails objectForKey:kParam_anniversary];
            
            NSDictionary *ocsDic= [NSDictionary dictionaryWithObjectsAndKeys:occasionStr,@"name",occasionDate,@"date", nil];
            if ([self.occasionArr containsObject:ocsDic]) {
                
            }
            else
            {
                [self.occasionArr addObject:ocsDic];
            }
            
            SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
            
            NSString *jsonString = [jsonWriter stringWithObject:self.occasionArr];
            
            delegate.occasionJsonStr = [jsonString copy];
            
            
            [self refreshOccasion];
        }
        
    } else
    {
      self.items = nil;
    }
      
      [self.tableView reloadData];
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view
                             animated:YES];
  } failure:^(NSError *er) {
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view
                             animated:YES];

  }];
}

- (void)generateScrollView {
  for (UIView *v in scrollView.subviews)
  {
    [v removeFromSuperview];
  }

  NSUInteger index = 0;
  for (id dict in self.items) {
    [scrollView addSubview:[self generateView:dict forIndex:index]];
    index++;
  }

  [scrollView addSubview:[self generateAddButtonForIndex:index]];
  index = index + 2;
  [scrollView setContentSize:CGSizeMake(index * 55, 65)];
}

- (UIView *)generateAddButtonForIndex:(NSUInteger)idx {
  UIView *containerView =
      [[UIView alloc] initWithFrame:CGRectMake((55 * idx) + 10, 10, 45, 45)];
  [containerView.layer setCornerRadius:45.0f / 2.0f];
  [containerView.layer setBorderColor:GT_RED.CGColor];
  [containerView.layer setBorderWidth:0.5f];
  UIImageView *contentImageView =
      [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
  [contentImageView setContentMode:UIViewContentModeCenter];
  [contentImageView setImage:[UIImage imageNamed:@"plus"]];
  [containerView addSubview:contentImageView];
  UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
  [btn setFrame:contentImageView.frame];
  [btn setTag:idx];
  [btn addTarget:self
                action:@selector(addLovedOne)
      forControlEvents:UIControlEventTouchUpInside];
  [containerView addSubview:btn];
  return containerView;
}

- (UIView *)generateView:(id)dict forIndex:(NSUInteger)idx {
  UIView *containerView =
      [[UIView alloc] initWithFrame:CGRectMake((55 * idx) + 10, 10, 45, 45)];
  [containerView.layer setCornerRadius:45.0f / 2.0f];
  [containerView.layer setBorderColor:GT_RED.CGColor];
  [containerView.layer setBorderWidth:0.5f];
  [containerView setClipsToBounds:YES];
  UIImageView *contentImageView =
      [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
  [contentImageView
      setImageWithURL:[NSURL URLWithString:[[self.items valueForKey:kParam_image] objectAtIndex:idx]]];
    
  [containerView addSubview:contentImageView];
  UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
  [btn setFrame:contentImageView.frame];
  [btn setTag:idx];
  [btn addTarget:self
                action:@selector(editLovedOne:)
      forControlEvents:UIControlEventTouchUpInside];
  [containerView addSubview:btn];
  return containerView;
}

- (void)loadEditMode:(NSDictionary *)details {
  userDetails = [[NSMutableDictionary alloc] initWithDictionary:details] ;
    
    NSArray *allKeys = [userDetails allKeys];
    for (int i = 0; i < [allKeys count]; i++) {
        
        NSString *key = [allKeys objectAtIndex:i];
        
        id object = [self objectOrNilForKey:key fromDictionary:details];
        NSLog(@"object %@  and key %@",object,key);
        [userDetails setValue:[self objectOrNilForKey:key fromDictionary:details] forKey:key];
        
    }
    
//  subTitles = [NSMutableArray arrayWithArray:@[
//    userDetails[@"relation"],
//    userDetails[@"lives_in"],
//    userDetails[@"likes"],
//    userDetails[@"birthday"],
//    userDetails[@"anniversary"],
//    userDetails[@"maximum"],
//    userDetails[@"minimum"]
    
  //]];
}

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict
{
    id object = [dict objectForKey:aKey];
    if ([object isEqual:[NSNull null]] || [object isEqual:nil] || [object isEqual: @"<null>"]) {
        return @"";
    }
    else
        return object;
    //return [object isEqual:[NSNull null]] ? nil : object;
}

- (void)loadSubChild:(NSString *)parentId withType:(NSUInteger)type {
  self.userId = parentId;
  self.type = type;
}

- (IBAction)saveButton:(id)sender
{
    [self.view endEditing:YES];
    for (int i=0 ; i < 3; i++) {
        
        //  NSString *str = [subTitles objectAtIndex:i];
        
        NSString *str = [userDetails valueForKey:[serverKeys objectAtIndex:i]];
        NSString *title = [titles objectAtIndex:i];
        
        if (str.length <= 0 || self.nameLbl.text.length <= 0) {
            
            if ([title isEqualToString:@"Occasion"])   /// checking anniversary value becoz its optional
            {
                continue;
            }
            [[[UIAlertView alloc]
              initWithTitle:@""
              message:@"Please fill in all the details to add the person."
              delegate:nil
              cancelButtonTitle:@"OK"
              otherButtonTitles:nil] show];
            
            return;
        }
        
    }
    NSLog(@"%ld,min-%ld",maximumBudget,minimumBudget);
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
    
    NSString *age = [userDetails valueForKey:kParam_age];
    age = [age stringByReplacingOccurrencesOfString:@" Years"
                                     withString:@""];
    
    [userDetails setValue:age forKey:kParam_age];
    
    [userDetails setValue:self.nameLbl.text forKey:kParam_first_name];
    [userDetails setValue:[NSString stringWithFormat:
                           @"%ld", (unsigned long)(self.userId
                                                   ? self.type
                                                   : self.personType.selectedSegmentIndex + 1)] forKey:kParam_type];
    
    if (self.occasionArr.count >0) {
        NSDictionary *ocsDic = [self.occasionArr objectAtIndex:0];
        [userDetails setObject:[ocsDic objectForKey:@"name"] forKey:kParam_birthday];
        [userDetails setObject:[ocsDic objectForKey:@"date"] forKey:kParam_anniversary];
    }
    
    if (delegate.occasionJsonStr!=nil)
    {
        NSMutableArray *ocsnameArr = [[NSMutableArray alloc]init];
        NSMutableArray *ocsdateArr = [[NSMutableArray alloc] init];
        
        for (int i = 0; i<self.occasionArr.count; i++) {
            NSDictionary *dic= [self.occasionArr objectAtIndex:i];
            
            [ocsnameArr addObject:[dic valueForKey:@"name"]];
            [ocsdateArr addObject:[dic valueForKey:@"date"]];
        }

        [userDetails setObject:ocsnameArr forKey:@"occasion_name"];
        [userDetails setObject:ocsdateArr forKey:@"occasion_date"];
    }
    
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:userDetails];
    
    if (self.userId)
    {
        params[@"parent_id"] = self.userId;
    }
    
    if (userDetails) {
        params[@"id"] = userDetails[@"id"];
        //[MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        
        hud.labelText = @"Feels good to Dabo";
        [[GTAPIClient sharedInstance] savePerson:params
                                   withPhotoData:self.profileImageView.image
         ? UIImageJPEGRepresentation(
                                     self.profileImageView.image, 0.8)
                                                : nil
                                     withSuccess:^{
                                         [MBProgressHUD hideAllHUDsForView:self.navigationController.view
                                                                  animated:YES];
                                         
                                         [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isUpdated"];
                                         [self.navigationController popViewControllerAnimated:YES];
                                     }
                                         failure:^(NSError *er) {
                                             [[[UIAlertView alloc] initWithTitle:@""
                                                                         message:@"An error occured while adding "
                                               @"the person. Please try again."
                                                                        delegate:nil
                                                               cancelButtonTitle:@"OK"
                                                               otherButtonTitles:nil] show];
                                             [MBProgressHUD hideAllHUDsForView:self.navigationController.view
                                                                      animated:YES];
                                         }];
        
    }
    else
    {
        [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [[GTAPIClient sharedInstance] addPerson:params
                                  withPhotoData:self.profileImageView.image
         ? UIImageJPEGRepresentation(
                                     self.profileImageView.image, 0.8)
                                               : nil
                                    withSuccess:^{
                                        [MBProgressHUD hideAllHUDsForView:self.navigationController.view
                                                                 animated:YES];
                                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isUpdated"];
                                        [self.navigationController popViewControllerAnimated:YES];
                                    }
                                        failure:^(NSError *er) {
                                            [[[UIAlertView alloc] initWithTitle:@""
                                                                        message:@"An error occured while adding "
                                              @"the person. Please try again."
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil] show];
                                            [MBProgressHUD hideAllHUDsForView:self.navigationController.view
                                                                     animated:YES];
                                        }];
    }
}

- (IBAction)selectImage:(id)sender
{
  [takeController takePhotoOrChooseFromLibrary];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)takeController:(FDTakeController *)controller
              gotPhoto:(UIImage *)photo
              withInfo:(NSDictionary *)info {
  [[UIApplication sharedApplication]
      setStatusBarStyle:UIStatusBarStyleLightContent];
  [self.profileImageView setImage:photo];
}

#pragma mark - Add Occasion Button

- (IBAction)addOcassion:(id)sender
{
    AddMoreOccasionsVC *moreOcassion = (AddMoreOccasionsVC *)[self.storyboard instantiateViewControllerWithIdentifier:@"AddMoreOccasionsVC"];
    moreOcassion.isEdit = FALSE;
    [self.navigationController pushViewController:moreOcassion animated:YES];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
    
  return 4+[self.occasionArr count];
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == budgetCellIndex) {
        
        return 70;
    }

  return [ProfileEditCell getHight];
}


-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
//        minimumBudget =  [subTitles[6] integerValue];
//        maximumBudget = [subTitles[5] integerValue];
    
    minimumBudget =  [[userDetails valueForKey:kParam_minimum] integerValue];
    maximumBudget = [[userDetails valueForKey:kParam_maximum] integerValue];
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdentifier = [ProfileEditCell cellIdentifier];

    if (indexPath.row == budgetCellIndex) {
        
        cellIdentifier = @"BudgetCell";
    }

    cell =
    [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[ProfileEditCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier];
    }
    
    NSArray *images =
    @[@"conn",@"locationPin",@"heart",@"wallet"];
    
    NSLog(@"%ld",(long)indexPath.row);
   // cell.selectionLbl.text = subTitles[indexPath.row];
    
    [cell.typeImageView setTintColor:GT_RED];
    
    if (indexPath.row == budgetCellIndex)   // for budget Cell
    {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.minBudget = (UITextField *)[cell viewWithTag:301];
        cell.minBudget.text=[userDetails valueForKey:kParam_minimum];
        cell.maxBudget = (UITextField *)[cell viewWithTag:302];
        cell.maxBudget.text=[userDetails valueForKey:kParam_maximum];
        
        minimumBudget =  [cell.minBudget.text integerValue];
        maximumBudget = [cell.maxBudget.text integerValue];
     }
    else if (indexPath.row >3)  // for occasion cell
    {
        NSDictionary *ocsDic = [self.occasionArr objectAtIndex:indexPath.row-4];
        cell.nameLbl.text = @"Occasion";
        cell.selectionLbl.text = [NSString stringWithFormat:@"%@ / %@",[ocsDic valueForKey:@"name"],[ocsDic valueForKey:@"date"]];
        cell.typeImageView.image = [[UIImage imageNamed:@"cal"]
                                    imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    else  // for first three cell
    {
        cell.selectionLbl.text = [userDetails valueForKey:serverKeys[indexPath.row]];
        cell.nameLbl.text = titles[indexPath.row];
        cell.typeImageView.image = [[UIImage imageNamed:images[indexPath.row]]
                                    imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    
  return cell;
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [pickerView removeFromSuperview];
  [self.view endEditing:YES];
    
    [[self.view viewWithTag:1001] removeFromSuperview];
    [[self.view viewWithTag:1002] removeFromSuperview];
  //  [view removeFromSuperview];
    selectedIndex = indexPath;

    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

  if (indexPath.row == 1) {
    MDSGeocodingViewController *geoCoding = [[MDSGeocodingViewController alloc]
        initWithNibName:@"MDSGeocodingViewController"
                 bundle:nil];
    [geoCoding setDelegate:(id<MDSGeoCodingDelegate>)self];
    [self.navigationController pushViewController:geoCoding animated:YES];
    return;

  } else if (indexPath.row == 2) {
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
      
     // NSString *oldValues = subTitles[indexPath.row];;
    NSString *oldValues = [userDetails valueForKey:[serverKeys objectAtIndex:indexPath.row]];
      
      if (oldValues) {
          
          [[alert textFieldAtIndex:0] setText:oldValues];
      }
      
    [alert setDelegate:self];
    [[alert textFieldAtIndex:0] setDelegate:(id<UITextFieldDelegate>)self];
    [alert setTag:102];
    [alert show];
    return;
  }else if (indexPath.row >3) {
      
     //  NSArray * occArr = [occasionDic allKeys];
      AddMoreOccasionsVC *moreOcassion = (AddMoreOccasionsVC *)[self.storyboard instantiateViewControllerWithIdentifier:@"AddMoreOccasionsVC"];
      moreOcassion.isEdit = TRUE;
      
      NSDictionary *ocsDic = [self.occasionArr objectAtIndex:indexPath.row-4];
      
      moreOcassion.occTypeStr = [NSString stringWithFormat:@"%@",[ocsDic valueForKey:@"name"]];
      moreOcassion.occDateStr = [NSString stringWithFormat:@"%@",[ocsDic valueForKey:@"date"]];
                                 
      [self.navigationController pushViewController:moreOcassion animated:YES];
    }
    
    if (indexPath.row == 0)
    {
        pickerView = [self makeAPicker:indexPath.row];
        
        UIView *view = [[UIView alloc]
                        initWithFrame:CGRectMake(0, self.view.frame.size.height - 200, self.view.frame.size.width, 240)];
        
        view.tag = 1001;
        
        [self addToolbar:view];
        
        [view addSubview:pickerView];
        
        [self.view addSubview:view];
        
        NSMutableArray *items = nil;
        
        items = [[NSMutableArray alloc] initWithArray:[@[
                                                         @"Friend",
                                                         @"Wife",
                                                         @"Mother",
                                                         @"Father",
                                                         @"Sister",
                                                         @"Brother",
                                                         @"Son",
                                                         @"Daughter",
                                                         @"Boyfriend",
                                                         @"Girlfriend"
                                                         ] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
        
        [pickerView setTitles:@[ items ]];
        
        [pickerView
         handleSelectionWithBlock:^void(UIPickerView *pickerView, NSInteger row,
                                        NSInteger component) {
             
            // [subTitles replaceObjectAtIndex:indexPath.row withObject:items[row]];
              [userDetails setValue:items[row] forKey:[serverKeys objectAtIndex:indexPath.row]];
             [tableView reloadData];
         }];
        
        NSString *indexValue = [userDetails valueForKey:[serverKeys objectAtIndex:indexPath.row]];
        
        if ([indexValue length] <= 0) {
           // [subTitles replaceObjectAtIndex:indexPath.row withObject:items[0]];
            [userDetails setValue:items[0] forKey:[serverKeys objectAtIndex:indexPath.row]];
            [tableView reloadData];
            
        }
  }

    /*
  else if (indexPath.row == 5){
      
      self.tableView.frame= CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height-200);
      [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
//      items = [[NSMutableArray alloc]
//              initWithArray:[@[ @"Birthday", @"Anniversary", @"Valentine's Day", ]
//                             sortedArrayUsingSelector:
//                             @selector(localizedCaseInsensitiveCompare:)]];
      
      items = [[NSMutableArray alloc] init];
      for(int x = 0; x < 150; x++)
      {
          [items addObject:[NSString stringWithFormat:@"%i-%i", x, x+10]];
          x=x+9;
      }
      
      for (int x = 150; x< 170; x++) {
          [items addObject:[NSString stringWithFormat:@"%i-%i", x, x+20]];
          x=x+20;
      }
      
      for (int x = 170; x< 200; x++) {
          [items addObject:[NSString stringWithFormat:@"%i-%i", x, x+30]];
          x=x+30;
      }
      
      for (int x = 200; x< 500; x++) {
          [items addObject:[NSString stringWithFormat:@"%i-%i", x, x+50]];
          x=x+49;
      }
      
      [items addObject:@"500-XXX"];
      
      NSLog(@"%@",items);
      
      
  }

     */

  
}

#pragma mark - Picker

-(void)datePicker :(NSUInteger)row{
    
    datePicker=[[UIDatePicker alloc] initWithFrame:CGRectMake(0, 40, self.view.frame.size.width, 160)];
    datePicker.datePickerMode = UIDatePickerModeDate;
    datePicker.hidden = NO;
    datePicker.backgroundColor=[UIColor whiteColor];
    datePicker.date = [NSDate date];
    
    [datePicker addTarget:self
                   action:@selector(ChangeValue:)
         forControlEvents:UIControlEventValueChanged];
    
    NSDateFormatter * df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"M-d-yyyy"]; // from here u can change format..
    NSLog(@"%@",label.selectionLbl.text);
    label.selectionLbl.text=[df stringFromDate:datePicker.date];
    
}

- (void)ChangeValue:(id)sender{
    
    NSIndexPath *indexpath=selectedIndex;
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"M-d-yyyy"];
    
//    subTitles[indexpath.row] = [NSString stringWithFormat:@"%@",
//                          [df stringFromDate:datePicker.date]];
    
    [userDetails setValue:[NSString stringWithFormat:@"%@",
                           [df stringFromDate:datePicker.date]] forKey:[serverKeys objectAtIndex:indexpath.row]];
    
    NSLog(@"%@",[NSString stringWithFormat:@"%@",
                 [df stringFromDate:datePicker.date]]);
   
}

- (UIPickerView *)makeAPicker:(NSUInteger)row
{
    UIPickerView *myPickerView = [[UIPickerView alloc]
                                  initWithFrame:CGRectMake(0, 40, self.view.frame.size.width, 160)];
    myPickerView.backgroundColor = [UIColor whiteColor];
    myPickerView.showsSelectionIndicator = YES;
    myPickerView.tag = row;
    
    return myPickerView;
}

- (void)addToolbar:(UIView *)view
{
    UIToolbar *doneToolbar = [[UIToolbar alloc]
                              initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    doneToolbar.barStyle = UIBarStyleDefault;
    
    UIBarButtonItem *selectBtn =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"Done")
                                     style:UIBarButtonItemStyleDone
                                    target:self
                                    action:@selector(selectBtn:)];
    
    
    [selectBtn setTitleTextAttributes:@{
                                        NSFontAttributeName : SKIA_REGULAR(16),
                                        NSForegroundColorAttributeName : GT_RED
                                        } forState:UIControlStateNormal];
    
    [selectBtn setTintColor:GT_RED];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Clear", @"Clear")
                                     style:UIBarButtonItemStyleDone
                                    target:self
                                    action:@selector(cancelButton:)];
    
    [cancelButton setTitleTextAttributes:@{
                                           NSFontAttributeName : SKIA_REGULAR(16),
                                           NSForegroundColorAttributeName : GT_RED
                                           } forState:UIControlStateNormal];
    
    [cancelButton setTintColor:GT_RED];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    doneToolbar.items = @[cancelButton, flexibleSpace, selectBtn ];
    
    [doneToolbar sizeToFit];
    
    [view addSubview:doneToolbar];
}

- (void)cancelButton:(id)sender
{
 //   [subTitles replaceObjectAtIndex:selectedIndex.row withObject:@""];

    [userDetails setValue:@"" forKey:[serverKeys objectAtIndex:selectedIndex.row]];
    
    [[self.view viewWithTag:1001] removeFromSuperview];
    [[self.view viewWithTag:1002] removeFromSuperview];
    [self.tableView reloadData];
    
    [self updateTableViewFrame:0];

}

- (void)selectBtn:(id)sender
{
  [[self.view viewWithTag:1001] removeFromSuperview];
  [[self.view viewWithTag:1002] removeFromSuperview];
  [self.tableView reloadData];
    
    [self updateTableViewFrame:0];

   //[datePicker removeFromSuperview];
}

- (void)closeKeyboard:(id)sender {
  [[self.view viewWithTag:1001] removeFromSuperview];
  [pickerView setHidden:YES];
}

- (void)alertView:(UIAlertView *)alertView
    clickedButtonAtIndex:(NSInteger)buttonIndex {
  NSString *inputText = [[alertView textFieldAtIndex:0] text];

  if (buttonIndex == 1) {
    if (alertView.tag == 101) {
        
    //  [subTitles replaceObjectAtIndex:1 withObject:inputText];
        [userDetails setValue:inputText forKey:kParam_lives_in];
    } else if (alertView.tag == 102) {
          [userDetails setValue:inputText forKey:kParam_likes];
      //[subTitles replaceObjectAtIndex:2 withObject:inputText];
    }
  }
    
  [self.tableView reloadData];
    
}

- (void)selectedLocation:(NSString *)locationInformation
         withCoordinates:(CLLocationCoordinate2D)coordinate {
 // [subTitles replaceObjectAtIndex:1 withObject:locationInformation];
    [userDetails setValue:locationInformation forKey:kParam_lives_in];
  [self.tableView reloadData];
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)dismiss
{
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)updateTableViewFrame:(NSInteger)y
{
    //[UIView animateWithDuration:0.25 animations:^{
    
    [self.tableView setContentOffset:CGPointMake(0, y) animated:YES];
    
       // [self.tableView scrollRectToVisible:CGRectMake(0, y, self.tableView.frame.size.height, self.tableView.frame.size.width) animated:YES];
    //}];
}

- (void)updateBackgroundViewFrame:(NSInteger)y
{
    [UIView animateWithDuration:0.25 animations:^{
        
        CGRect frame        = self.view.frame;
        frame.origin.y      = y;
        self.view.frame     = frame;
        
    }];
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
        NSString *stringMin = [NSString stringWithFormat:@"%ld", (long)minimumBudget];
       // [subTitles replaceObjectAtIndex:6 withObject:stringMin];
        [userDetails setValue:stringMin forKey:kParam_minimum];
    }
    
    if (textField.tag == 302)
    {
        maximumBudget = [[textField text] integerValue];
        NSString *stringMax = [NSString stringWithFormat:@"%ld", (long)maximumBudget];
        //[subTitles replaceObjectAtIndex:5 withObject:stringMax];
        [userDetails setValue:stringMax forKey:kParam_maximum];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  GTChildLovedOneViewController *destination = segue.destinationViewController;
  [destination setUserId:userDetails[kParam_id]];
  [destination setType:[userDetails[kParam_type] integerValue]];
}

- (void)editLovedOne:(UIButton *)btn {
  NSUInteger idx = btn.tag;

  UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
  AddPersonViewController *vc = (AddPersonViewController *)
      [sb instantiateViewControllerWithIdentifier:@"AddPersonViewController"];
  [vc loadSubChild:userDetails[kParam_id]
          withType:[userDetails[kParam_type] integerValue]];
  [vc loadEditMode:self.items[idx]];
  [self.navigationController pushViewController:vc animated:YES];
}
- (void)addLovedOne {
  UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
  AddPersonViewController *vc = (AddPersonViewController *)
      [sb instantiateViewControllerWithIdentifier:@"AddPersonViewController"];
  [vc loadSubChild:userDetails[kParam_id]
          withType:[userDetails[kParam_type] integerValue]];
  [self.navigationController pushViewController:vc animated:YES];
}
@end
