//
//  ChangePasswordViewController.m
//  Gifter
//
//  Created by Macwaves on 9/2/15.
//
//

#import "ChangePasswordViewController.h"
#import "KTUtility.h"
#import "KTUtility.h"
#import "ProfileEditCell.h"
#import "GTAPIClient.h"
#import "Constants.h"
#import "MDSGeocodingViewController.h"
#import "ChangePasswordViewController.h"
#import <UIImageView+AFNetworking.h>

@interface ChangePasswordViewController ()
@property(nonatomic,strong) IBOutlet UIButton *saveButton;
@property (nonatomic,retain) IBOutlet UIImageView *passwordImage;
@property (nonatomic,retain) IBOutlet UIImageView *comfrimPasswordImage;
@end

@implementation ChangePasswordViewController
@synthesize userName;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [KTUtility setButtonUI:_saveButton];
    self.navigationItem.title = @"Change Password";
    

    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    

    _passwordImage.image = [[UIImage imageNamed:@"PasswordIcn"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _comfrimPasswordImage.image = [[UIImage imageNamed:@"PasswordIcn"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    [_passwordImage setTintColor:GT_RED];
    [_comfrimPasswordImage setTintColor:GT_RED];
    
    
    [KTUtility setTextFieldBordersRed:self.changePass
                          withLeftImage:[[UIImage imageNamed:@"PasswordIcn"]
                                         imageWithRenderingMode:
                                         UIImageRenderingModeAlwaysTemplate]];
    
    [KTUtility setTextFieldBordersRed:self.confirmPass
                        withLeftImage:[[UIImage imageNamed:@"PasswordIcn"]
                                       imageWithRenderingMode:
                                       UIImageRenderingModeAlwaysTemplate]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)updateProfile:(id)info {
    if ([info isKindOfClass:[NSDictionary class]]) {
        [[GTAPIClient sharedInstance] saveProfile:info
                                    withPhotoData:nil
                                      withSuccess:^{
                                          
                                          [MBProgressHUD hideAllHUDsForView:self.navigationController.view  animated:YES];
                                          
                                          [self.navigationController popViewControllerAnimated:YES];
                                          [[[UIAlertView alloc] initWithTitle:@"" message:@"You have successfully change your password." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                                      }
                                          failure:^(NSError *er){
                                          }];
    }
}



-(IBAction)save:(id)sender{
    
    NSString *Pass         = self.changePass.text;
    NSString *cofpass         =  self.confirmPass.text;
    
   if ([Pass isEqualToString:@""]) {

       NSString *message = @"Please enter your password";
       
       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
       [alert show];
       [self.changePass becomeFirstResponder];
    }
    
   else if  ([cofpass isEqualToString:@""]) {
       
       NSString *message = @"Please enter confirm password";
       
       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
       [alert show];
       [self.confirmPass becomeFirstResponder];
       
   }
    else if  (![cofpass isEqualToString:Pass]) {
        
        NSString *message = @"Password does not matched";
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        [self.confirmPass becomeFirstResponder];
        
    }
    else{
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.labelText = @"Updating Password...";
        
        [self updateProfile:@{
                              @"first_name" : self.userName ? self.userName : @"",
                              @"password" : self.changePass.text ? self.changePass.text : @""
                              }];
    }

}


-(void) touchesEnded: (NSSet *) touches withEvent: (UIEvent *) event
{
    [self.changePass resignFirstResponder];
    [self.confirmPass resignFirstResponder];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
   [textField resignFirstResponder];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
