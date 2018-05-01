//
//  GTAddressAddViewController.m
//  Gifter
//
//  Created by Karthik on 19/04/2015.
//
//

#import "GTAddressAddViewController.h"
#import "KTUtility.h"
#import "GTAPIClient.h"

@interface GTAddressAddViewController ()
@property(nonatomic, weak) IBOutlet UITextField *addressStreetTxt, *cityTxt,
    *zipTxt, *countryTxt;
@property(nonatomic, weak) IBOutlet UIButton *saveButton;

@end

@implementation GTAddressAddViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [KTUtility setButtonUI:self.saveButton];
  self.title = @"Add Address";
  // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (IBAction)addAddress:(id)sender {
  [self.view endEditing:YES];
  if ([[self.addressStreetTxt.text
          stringByTrimmingCharactersInSet:
              [NSCharacterSet whitespaceAndNewlineCharacterSet]] length] &&
      [[self.cityTxt.text
          stringByTrimmingCharactersInSet:
              [NSCharacterSet whitespaceAndNewlineCharacterSet]] length] &&
      [[self.zipTxt.text
          stringByTrimmingCharactersInSet:
              [NSCharacterSet whitespaceAndNewlineCharacterSet]] length] &&
      [[self.countryTxt.text
          stringByTrimmingCharactersInSet:
              [NSCharacterSet whitespaceAndNewlineCharacterSet]] length]) {
    NSDictionary *params = @{
      @"street" : self.addressStreetTxt.text,
      @"city" : self.cityTxt.text,
      @"zip" : self.zipTxt.text,
      @"country" : self.countryTxt.text
    };
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];

    [[GTAPIClient sharedInstance] addAddress:params
        withSuccess:^{
          [MBProgressHUD hideAllHUDsForView:self.navigationController.view
                                   animated:YES];
          [[self navigationController] popViewControllerAnimated:YES];
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

  } else {
    [[[UIAlertView alloc]
            initWithTitle:@""
                  message:@"Please fill in all the details to add the address."
                 delegate:nil
        cancelButtonTitle:@"OK"
        otherButtonTitles:nil] show];
  }
}

@end
