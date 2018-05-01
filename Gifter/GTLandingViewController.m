//
//  GTLandingViewController.m
//  Gifter
//
//  Created by Karthik on 21/03/2015.
//
//

#import "GTLandingViewController.h"
#import <QuartzCore/QuartzCore.h>

#import "KTUtility.h"
#import "GTAPIClient.h"
#import "ATLabel.h"
#import "GTAPIClient.h"
#import "FBLoginController.h"


@interface GTLandingViewController ()
@property(nonatomic, weak) IBOutlet UIButton *loginButton, *registerButton,
*facebookButton;
@property(nonatomic, weak) IBOutlet UITextField *usernameTxtField,
*passwordTxtField;
@property(nonatomic, weak) IBOutlet ATLabel *contentLabel;
@end

@implementation GTLandingViewController

#pragma mark - ViewController Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.navigationController.navigationBarHidden=NO;
    
     [self.navigationItem
     setBackBarButtonItem:[[UIBarButtonItem alloc]
                           initWithTitle:@""
                           style:UIBarButtonItemStyleDone
                           target:nil
                           action:nil]];
    //self.view.backgroundColor = GT_RED;
    /*
    [self.contentLabel animateWithWords:@[
                                          @"Simply select gifts from the list of suggested gifts…",
                                          @"Gifts based on friends likes, occasion and budget…",
                                          @"Easy to pay and ship the gifts to friends instantly…"
                                          ] forDuration:2.0f withAnimation:ATAnimationTypeSlideTopInBottomOut];
     
    */
    [self setupUI];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:YES];
}

- (BOOL)hidesBottomBarWhenPushed {
    return NO;
}



- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - User Interaction

- (IBAction)openRegisteration:(id)sender {
    [self performSegueWithIdentifier:@"REGISTER" sender:nil];
}

- (IBAction)openLogin:(id)sender {
    
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

- (IBAction)loginWithFacebook:(id)sender {
    
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];

    [[MBProgressHUD HUDForView:self.navigationController.view] setLabelText:NSLocalizedString(@"Authenticating ...", @"")];
   
    [[FBLoginController fbAccountsManager] FacebookLogin:^(NSArray *userInfo){
        
        if (userInfo) {
            
            [self sendFacebookInfoForRegistering:userInfo];
        }
        else
        {
            [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];

            [[[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"Unable to access " @"your facebook " @"information.", @"")
              delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil] show];
        }
    }];
    
//    [self.view endEditing:YES];
//    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
//
//    [[MBProgressHUD HUDForView:self.navigationController.view]
//
//     setLabelText:NSLocalizedString(@"Requesting authorization ...", @"")];
//    if (FBSession.activeSession.state == FBSessionStateOpen ||
//        FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
//        [self requestUserInformation];
//
//    } else
//    {
//        [FBSession openActiveSessionWithReadPermissions:@[
//                                                          @"public_profile,email"
//                                                          ] allowLoginUI:YES completionHandler:^(FBSession *session,
//                                                                                                 FBSessionState state,
//                                                                                                 NSError *error) {
//                                                              if (error) {
//                                                                  [[[UIAlertView alloc]
//                                                                    initWithTitle:@""
//                                                                    message:NSLocalizedString(@"Unable to access "
//                                                                                              @"your facebook "
//                                                                                              @"information.",
//                                                                                              @"")
//                                                                    delegate:nil
//                                                                    cancelButtonTitle:NSLocalizedString(@"OK", @"")
//                                                                    otherButtonTitles:nil] show];
//                                                              } else {
//                                                                  [self requestUserInformation];
//                                                              }
//                                                          }];
//    }
}

#pragma mark - Facebook Login

- (void)requestUserInformation {
   
//    [[MBProgressHUD HUDForView:self.navigationController.view]
//     setLabelText:NSLocalizedString(@"Accessing Facebook info. ...", @"")];
//    FBRequestConnection *newConnection = [[FBRequestConnection alloc] init];
//    FBRequest *request = [[FBRequest alloc]
//                          initWithSession:FBSession.activeSession
//                          graphPath:@"/me"
//                          parameters:[NSMutableDictionary
//                                      dictionaryWithObjectsAndKeys:
//                                      @"name,picture,first_name,last_name,email",
//                                      @"fields", nil]
//                          HTTPMethod:@"GET"];
//    
//    [newConnection addRequest:request
//            completionHandler:^(FBRequestConnection *connection, id result,
//                                NSError *error) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [MBProgressHUD hideAllHUDsForView:self.navigationController.view
//                                             animated:YES];
//                    if (error) {
//                        [[[UIAlertView alloc]
//                          initWithTitle:@""
//                          message:NSLocalizedString(@"Unable to access "
//                                                    @"your facebook "
//                                                    @"information.",
//                                                    @"")
//                          delegate:nil
//                          cancelButtonTitle:NSLocalizedString(@"OK", @"")
//                          otherButtonTitles:nil] show];
//                    } else {
//                        [self sendFacebookInfoForRegistering:result];
//                    }
//                    
//                });
//            }];
//    [newConnection start];
}

- (void)sendFacebookInfoForRegistering:(id)facebookResult
{
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    [[MBProgressHUD HUDForView:self.navigationController.view]
     setLabelText:NSLocalizedString(@"Registering ...", @"")];
    
    [[GTAPIClient sharedInstance] authenticateWithFacebook:facebookResult
                                                   success:^{
                                                      [MBProgressHUD hideAllHUDsForView:self.navigationController.view
                                                                                animated:YES];
                                                       
                                                       [[self.navigationController presentingViewController]
                                                        dismissViewControllerAnimated:YES
                                                        completion:^{
                                                            
                                                        }];
                                                        [[NSNotificationCenter defaultCenter] postNotificationName:@"isLogin" object:nil];
                                                       
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

#pragma mark - UI
- (void)setupUI {
    [KTUtility setRoundedButtonUI:_loginButton];
    
    [KTUtility setTextFieldLessBorders:_usernameTxtField
                         withLeftImage:[[UIImage imageNamed:@"icon-email"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [KTUtility setTextFieldWithoutBorders:_passwordTxtField
                            withLeftImage:[[UIImage imageNamed:@"icon-confirm-password"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
}

#pragma mark - Alert Delegation
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


@end
