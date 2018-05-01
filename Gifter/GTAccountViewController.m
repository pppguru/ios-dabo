//
//  GTAccountViewController.m
//  Gifter
//
//  Created by Karthik on 22/03/2015.
//
//

#import "GTAccountViewController.h"
#import "KTUtility.h"
#import "ProfileEditCell.h"
#import "GTAPIClient.h"
#import "Constants.h"
#import "MDSGeocodingViewController.h"
#import "ChangePasswordViewController.h"
#import <UIImageView+AFNetworking.h>

@implementation GTAccountViewController
- (void)viewDidLoad {
  [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = NO;
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isCalledFromLovedOne"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isCalledFromDidLoad"];
    self.navigationItem.title = NSLocalizedString(@"Account", @"");
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

    
    [self.usernameLbl setText:[[NSUserDefaults standardUserDefaults]
                                stringForKey:@"first_name"]];
    [self.password setText:[[NSUserDefaults standardUserDefaults]
                               stringForKey:@"password"]];
    [self.confPassword setText:[[NSUserDefaults standardUserDefaults]
                            stringForKey:@"password"]];
    

  if ([NSURL URLWithString:[[NSUserDefaults standardUserDefaults]
                               stringForKey:@"image"]]) {
    [[self profileImageView]
        setImageWithURL:[NSURL
                            URLWithString:[[NSUserDefaults standardUserDefaults]
                                              stringForKey:@"image"]]];
  }

  takeController = [[FDTakeController alloc] init];
  [takeController setDelegate:(id<FDTakeDelegate>)self];

  UIBarButtonItem *logoutButton =
      [[UIBarButtonItem alloc] initWithTitle:@"Logout"
                                       style:UIBarButtonItemStyleDone
                                      target:self
                                      action:@selector(logoutAction:)];
  [self.navigationItem setRightBarButtonItem:logoutButton];

  BOOL isOn1 =
      [[NSUserDefaults standardUserDefaults] boolForKey:@"ENABLE_NOTIFICATION"];
  BOOL isOn2 = [[NSUserDefaults standardUserDefaults]
      boolForKey:@"ENABLE_NOTIFICATION_PROMOTIONS"];

  [self.enableNotificationSwitch setOn:isOn1];
  [self.promotionNotificationSwitch setOn:isOn2];
    
}



-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    self.navigationController.navigationBarHidden = NO;
    
    [self.usernameLbl setText:[[NSUserDefaults standardUserDefaults]
                               stringForKey:@"first_name"]];
    [self.password setText:[[NSUserDefaults standardUserDefaults]
                            stringForKey:@"password"]];
    [self.confPassword setText:[[NSUserDefaults standardUserDefaults]
                                stringForKey:@"password"]];
    [self.tableView reloadData];
    
}

- (IBAction)switchAction:(UISwitch *)switchControl {
  if (switchControl.tag == 101) {
    [[NSUserDefaults standardUserDefaults] setBool:switchControl.isOn
                                            forKey:@"ENABLE_NOTIFICATION"];
    [[NSUserDefaults standardUserDefaults] synchronize];
  } else {
    [[NSUserDefaults standardUserDefaults]
        setBool:switchControl.isOn
         forKey:@"ENABLE_NOTIFICATION_PROMOTIONS"];
    [[NSUserDefaults standardUserDefaults] synchronize];
  }
}

- (void)logoutAction:(id)sender {
    
    
    NSString *message   = @"Are you sure you want to logout?";
    NSString *no        = @"NO";
    NSString *yes       = @"YES";
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:self cancelButtonTitle:no otherButtonTitles:yes, nil];
    
    alert.tag = 203;
    
    [alert show];


}

#pragma mark - Alert Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 203) {
        
        if (buttonIndex == 1)
        {
            
            for (UINavigationController *nv in self.navigationController.tabBarController
                 .viewControllers) {
                [nv popToRootViewControllerAnimated:NO];
            }
            
            [KTUtility removeAllUserDefaultValues];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CART"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[GTAPIClient sharedInstance] logoutUser];
            
            
             [[NSNotificationCenter defaultCenter] postNotificationName:@"logoutGiftView" object:self userInfo:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"logoutLovedOne" object:self userInfo:nil];
          
        }
        
        else if (buttonIndex == 0){
            
            [alertView removeFromSuperview];
        }
    }
    
}


- (void)plusAction:(id)sender {
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
  return 1;
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSString *cellIdentifier = [ProfileEditCell cellIdentifier];

  ProfileEditCell *cell =
      [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (cell == nil) {
    cell = [[ProfileEditCell alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:cellIdentifier];
  }
  NSArray *titlesArray =
      @[ @"Change Password", @"Account History", @"Location" ];
  NSArray *subTitlesArray = @[
    @"No Saved Payment Methods",
    @"No Previous Orders",
    [[NSUserDefaults standardUserDefaults] valueForKey:@"USER_LOCATION"]
        ? [[NSUserDefaults standardUserDefaults] valueForKey:@"USER_LOCATION"]
        : @"Enter a location",
  ];
  NSArray *iconsArray = @[ @"PasswordIcn", @"wallet", @"locationPin" ];

  cell.nameLbl.text = titlesArray[indexPath.row];
  cell.selectionLbl.text = subTitlesArray[indexPath.row];
  cell.typeImageView.image = [[UIImage imageNamed:iconsArray[indexPath.row]]
      imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  [cell.typeImageView setTintColor:GT_RED];
  return cell;
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        //[self performSegueWithIdentifier:@"ACCOUNT_HISTORY" sender:nil];
        
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                 bundle: nil];
        ChangePasswordViewController *changePassVC = (ChangePasswordViewController*)[mainStoryboard
                                                                                          instantiateViewControllerWithIdentifier: @"ChangePasswordViewController"];
        changePassVC.userName = self.usernameLbl.text;
        [self.navigationController pushViewController:changePassVC animated:YES];
    }
    
  if (indexPath.row == 1) {
    //[self performSegueWithIdentifier:@"ACCOUNT_HISTORY" sender:nil];
  } else if (indexPath.row == 2) {
    MDSGeocodingViewController *geoCoding = [[MDSGeocodingViewController alloc]
        initWithNibName:@"MDSGeocodingViewController"
                 bundle:nil];
    [geoCoding setDelegate:(id<MDSGeoCodingDelegate>)self];
    [self.navigationController pushViewController:geoCoding animated:YES];
    return;
  }
}

- (void)selectedLocation:(NSString *)locationInformation
         withCoordinates:(CLLocationCoordinate2D)coordinate {
  [[NSUserDefaults standardUserDefaults] setValue:locationInformation
                                           forKey:@"USER_LOCATION"];
  [self.tableView reloadData];
  [self.navigationController popViewControllerAnimated:YES];
  [self updateProfile:@{ @"address" : locationInformation }];
}

- (void)dismiss {
  [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)selectImage:(id)sender {
  [takeController takePhotoOrChooseFromLibrary];
}

- (void)updateProfile:(id)info {
  if ([info isKindOfClass:[NSDictionary class]]) {
    [[GTAPIClient sharedInstance] saveProfile:info
        withPhotoData:nil
        withSuccess:^{

        }
        failure:^(NSError *er){

        }];
  } else {
    [[GTAPIClient sharedInstance] saveProfile:nil
        withPhotoData:info
        withSuccess:^{

        }
        failure:^(NSError *er){

        }];
  }
}

- (void)takeController:(FDTakeController *)controller
              gotPhoto:(UIImage *)photo
              withInfo:(NSDictionary *)info {
  [[UIApplication sharedApplication]
      setStatusBarStyle:UIStatusBarStyleLightContent];
  [self.profileImageView setImage:photo];
  [self updateProfile:UIImageJPEGRepresentation(photo, 0.5)];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
  [self updateProfile:@{
    @"first_name" : self.usernameLbl.text ? self.usernameLbl.text : @""
   
  }];
  [super textFieldDidEndEditing:textField];
}


@end
