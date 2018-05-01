//
//  GTLoginViewController.m
//  Gifter
//
//  Created by Karthik on 21/03/2015.
//
//

#import "GTLoginViewController.h"
#import "KTUtility.h"
#import "GTAPIClient.h"
#import "PrivacyPolicyViewController.h"

@interface GTLoginViewController () <UIAlertViewDelegate, UITextFieldDelegate>{
    
    BOOL flag;
}
@property(nonatomic, weak) IBOutlet UITextField *usernameTxtField,
*passwordTxtField;
@property(nonatomic, weak) IBOutlet UIButton *loginButton;
@end

@implementation GTLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"Login", @"");
    
    [self.navigationItem
     setBackBarButtonItem:[[UIBarButtonItem alloc]
                           initWithTitle:@""
                           style:UIBarButtonItemStyleDone
                           target:nil
                           action:nil]];
    [KTUtility setButtonUI:_loginButton];
    UIBarButtonItem *forgotButton =
    [[UIBarButtonItem alloc] initWithTitle:@"Forgot?"
                                     style:UIBarButtonItemStyleDone
                                    target:self
                                    action:@selector(forgotPassword:)];
    [self.navigationItem setRightBarButtonItem:forgotButton];
}
- (void)forgotPassword:(id)sender {
    UIAlertView *forgotPasswordAlert = [[UIAlertView alloc]
                                        initWithTitle:nil
                                        message:NSLocalizedString(@"Please enter your email address:",
                                                                  @"")
                                        delegate:self
                                        cancelButtonTitle:@"Cancel"
                                        otherButtonTitles:NSLocalizedString(@"OK", @""), nil];
    [forgotPasswordAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [forgotPasswordAlert setDelegate:self];
    [[forgotPasswordAlert textFieldAtIndex:0] setText:self.usernameTxtField.text];
    [forgotPasswordAlert show];
}

- (IBAction)privacyPolicySelect:(id)sender {
    
//    [[UIApplication sharedApplication]
//     openURL:[NSURL URLWithString:@"http://www.google.com/"]];
    
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

-(IBAction)showpassword:(id)sender{
    
    BOOL isFirstResponder = _passwordTxtField.isFirstResponder; //store whether textfield is firstResponder
    
    if (isFirstResponder) [_passwordTxtField resignFirstResponder]; //resign first responder if needed, so that setting the attribute to YES works
    _passwordTxtField.secureTextEntry = !_passwordTxtField.secureTextEntry; //change the secureText attribute to opposite
    if (isFirstResponder) [_passwordTxtField becomeFirstResponder];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupUI];
}

- (void)setupUI {
    
    [KTUtility setTextFieldBordersWhite:_usernameTxtField
                     withLeftImage:[[UIImage imageNamed:@"EmailIcn"]
                                    imageWithRenderingMode:
                                    UIImageRenderingModeAlwaysTemplate]];
    [KTUtility setTextFieldBordersWhite:_passwordTxtField
                     withLeftImage:[[UIImage imageNamed:@"PasswordIcn"]
                                    imageWithRenderingMode:
                                    UIImageRenderingModeAlwaysTemplate]];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}


- (IBAction)loginAction:(id)sender {
    [self.view endEditing:YES];
    
//    
//    [[self.navigationController presentingViewController]
//     dismissViewControllerAnimated:YES
//     completion:^{
//         
//     }];
//    
//    return;
    
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

    else
    {
        
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    [[GTAPIClient sharedInstance]
     authenticateWithUsername:self.usernameTxtField.text
     andPassword:self.passwordTxtField.text
     success:^{
         
         [MBProgressHUD hideAllHUDsForView:self.navigationController.view
                                  animated:YES];
         [self.passwordTxtField setText:@""];
         
          [[NSNotificationCenter defaultCenter] postNotificationName:@"isLogin" object:nil];
         
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

- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self.view endEditing:YES];
        NSString *inputText = [[alertView textFieldAtIndex:0] text];
        
        if ([inputText length]) {
            if ([KTUtility validateEmail:inputText]) {
                [MBProgressHUD showHUDAddedTo:self.navigationController.view
                                     animated:YES];
                
                [[GTAPIClient sharedInstance]
                 forgotWithUsername:inputText
                 success:^{
                     
                     [MBProgressHUD hideAllHUDsForView:self.navigationController.view
                                              animated:YES];
                     
                     [[[UIAlertView alloc]
                       initWithTitle:@""
                       message:NSLocalizedString(
                                                 @"An email with "
                                                 @"instructions to recover "
                                                 @"your password has been "
                                                 @"sent to your account.",
                                                 "")
                       delegate:nil
                       cancelButtonTitle:NSLocalizedString(@"OK", @"")
                       otherButtonTitles:nil] show];
                 }
                 failure:^(NSError *er) {
                     
                     [MBProgressHUD hideAllHUDsForView:self.navigationController.view
                                              animated:YES];
                     
                     [[[UIAlertView alloc]
                       initWithTitle:@""
                       message:[er.userInfo valueForKey:@"error"]
                       delegate:nil
                       cancelButtonTitle:NSLocalizedString(@"OK", @"")
                       otherButtonTitles:nil] show];
                 }];
                
            } else {
                [[[UIAlertView alloc]
                  initWithTitle:@""
                  message:NSLocalizedString(@"Please enter a valid email "
                                            @"address in order to proceed "
                                            @"with recovery.",
                                            @"")
                  delegate:nil
                  cancelButtonTitle:NSLocalizedString(@"OK", @"")
                  otherButtonTitles:nil] show];
            }
        }
    }
}

#pragma mark -

@end
