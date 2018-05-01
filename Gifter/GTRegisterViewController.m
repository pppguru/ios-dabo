//
//  GTRegisterViewController.m
//  Gifter
//
//  Created by Karthik on 21/03/2015.
//
//

#import "GTRegisterViewController.h"
#import "KTUtility.h"
#import "GTAPIClient.h"
#import "FDTakeController.h"
#import "PrivacyPolicyViewController.h"

@interface GTRegisterViewController () {
  FDTakeController *takeController;
    BOOL isImageSelected;
}

@property(nonatomic, weak) IBOutlet UITextField *usernameTxtField,
    *passwordTxtField, *confirmPasswordTxtField;
@property(nonatomic, weak) IBOutlet UIButton *registerButton;
@property(nonatomic, assign) IBOutlet UIImageView *profileImageView;

@end

@implementation GTRegisterViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.navigationItem.title = NSLocalizedString(@"Register", @"");
  takeController = [[FDTakeController alloc] init];
  takeController.delegate = self;

  [self.navigationItem
      setBackBarButtonItem:[[UIBarButtonItem alloc]
                               initWithTitle:@""
                                       style:UIBarButtonItemStyleDone
                                      target:nil
                                      action:nil]];

  // Do any additional setup after loading the view.
}

- (IBAction)privacyPolicySelect:(id)sender {
    
//  [[UIApplication sharedApplication]
//      openURL:[NSURL URLWithString:@"http://www.google.com/"]];
    
    int tag = [(UIButton*)sender tag];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PrivacyPolicyViewController *vc = (PrivacyPolicyViewController *)
    [sb instantiateViewControllerWithIdentifier:@"privacy"];
    if (tag == 10) {
        vc.navTitle = @"Terms of Service";
        vc.docFileName = @"terms";
    }else{
        vc.navTitle = @"Privacy Policies";
        vc.docFileName = @"privacy_policy";
    }
    
    [self.navigationController pushViewController:vc animated:YES];
    
}


- (IBAction)selectImage:(id)sender {
  [takeController takePhotoOrChooseFromLibrary];
}


- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self setupUI];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}


- (void)setupUI {
    
    [KTUtility setRoundedButtonUI:_registerButton];
    
    [KTUtility setTextFieldLessBorders:_usernameTxtField
                         withLeftImage:[[UIImage imageNamed:@"icon-email"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [KTUtility setTextFieldLessBorders:_passwordTxtField
                         withLeftImage:[[UIImage imageNamed:@"icon-confirm-password"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [KTUtility setTextFieldLessBorders:_confirmPasswordTxtField
                         withLeftImage:[[UIImage imageNamed:@"icon-confirm-password"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    
    
}


- (IBAction)registerAction:(id)sender {
  [self.view endEditing:YES];
    
    NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];

    if ([_usernameTxtField.text isEqualToString:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Please enter your email address" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        [_usernameTxtField becomeFirstResponder];
    }
    else if  (![emailTest evaluateWithObject:_usernameTxtField.text] && [_usernameTxtField.text length]!=0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Please enter a valid email address" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        [_usernameTxtField becomeFirstResponder];
    }
    else if ([_passwordTxtField.text isEqualToString:@""]){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Please enter your password" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        [_passwordTxtField becomeFirstResponder];
    }
    else if ([_confirmPasswordTxtField.text isEqualToString:@""]){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Please confirm your password" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        [_confirmPasswordTxtField becomeFirstResponder];
    }else if (![_confirmPasswordTxtField.text isEqualToString:_passwordTxtField.text]){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Password and confirm password does not match. Please enter correct password." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [alertView show];
        [_confirmPasswordTxtField becomeFirstResponder];
    }
    else{
        
        [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [[MBProgressHUD HUDForView:self.navigationController.view]
         setLabelText:NSLocalizedString(@"Registering ...", @"")];
        
        UIImage *image = nil;
        if(isImageSelected){
            image = self.profileImageView.image;
        }else{
            image = nil;
        }
        [[GTAPIClient sharedInstance] registerWithUsername:self.usernameTxtField.text
                                               andPassword:self.passwordTxtField.text
                                                 withImage:image?UIImageJPEGRepresentation(image, 0.8):nil
                                                   success:^{
                                                       [[self.navigationController presentingViewController]
                                                        dismissViewControllerAnimated:YES
                                                        completion:^{
                                                        }];
                                                   }
                                                   failure:^(NSError *er) {
                                                       
                                                       [MBProgressHUD hideAllHUDsForView:self.navigationController.view
                                                                                animated:YES];
                                                       [[[UIAlertView alloc] initWithTitle:@""
                                                                                   message:[er.userInfo valueForKey:@"error"]
                                                                                  delegate:nil
                                                                         cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                                         otherButtonTitles:nil] show];
                                                   }];
    }
}


- (void)takeController:(FDTakeController *)controller
              gotPhoto:(UIImage *)photo
              withInfo:(NSDictionary *)info {
  [[UIApplication sharedApplication]
      setStatusBarStyle:UIStatusBarStyleLightContent];
  [self.profileImageView setImage:photo];
    
}


@end
