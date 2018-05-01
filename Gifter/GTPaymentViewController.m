//
//  GTPaymentViewController.m
//  Gifter
//
//  Created by Karthik on 20/04/2015.
//
//

#import "GTPaymentViewController.h"
#import "KTUtility.h"
#import  "GTGiftItemsViewController.h"
#import "GTAPIClient.h"
#import "Constants.h"



@interface GTPaymentViewController (){
    
    NSString *alertMsg;
}
@end

@implementation GTPaymentViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.title = @"Payment";
  [KTUtility setButtonUI:saveButton];
  // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self addToolbar:cardTxtField];
  [self addToolbar:cvcTxtField];
}

- (void)addToolbar:(UITextField *)txtField {
  // Toolbar to close the keyboard.
  UIToolbar *doneToolbar = [[UIToolbar alloc]
      initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
  doneToolbar.barStyle = UIBarStyleDefault;
  UIBarButtonItem *space = [[UIBarButtonItem alloc]
      initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                           target:nil
                           action:nil];
  UIBarButtonItem *close =
      [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil)
                                       style:UIBarButtonItemStyleDone
                                      target:self
                                      action:@selector(closeKeyboard:)];

  [close setTitleTextAttributes:@{
    NSFontAttributeName : SKIA_REGULAR(16),
    NSForegroundColorAttributeName : GT_RED
  } forState:UIControlStateNormal];
  [close setTintColor:GT_RED];
  doneToolbar.items = @[ space, close ];
  [doneToolbar sizeToFit];
  txtField.inputAccessoryView = doneToolbar;
}


#pragma mark - Stripe Pay
-(IBAction)payButtonAction :(id)sender
{
    if ([nameTxtField.text isEqualToString:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Please Enter Name" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [alertView show];
        [nameTxtField becomeFirstResponder];
    }
    
    else if ([cardTxtField.text isEqualToString:@""]){
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Please Enter Card Number" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [alertView show];
        [nameTxtField becomeFirstResponder];
        
    }
    
    else if ([expiryTxtField.text isEqualToString:@""]){
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Please Enter Expiry Date" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [alertView show];
        [nameTxtField becomeFirstResponder];
        
    }
    
    else if ([cvcTxtField.text isEqualToString:@""])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Please Enter CVV" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [alertView show];
        [nameTxtField becomeFirstResponder];
    }
    else{
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        STPCardParams *card = [[STPCardParams alloc] init];
        card.name =nameTxtField.text;
        card.number = cardTxtField.text;
        card.expMonth = selectedMonth;
        card.expYear = selectedYear;
        card.cvc = cvcTxtField.text;
        [[STPAPIClient sharedClient] createTokenWithCard:card
                                              completion:^(STPToken *token, NSError *error) {
                                                  if (error) {
                                                      [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                                      alertMsg = [NSString stringWithFormat:@"Invalid Card Detail"];
                                                      UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"" message:alertMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                      [theAlert show];
                                                      
                                                  } else
                                                  {
                                                      [self createBackendChargeWithToken:token completion:nil];
                                                  }
                                                  
                                              }];
    }
    
}

- (void)createBackendChargeWithToken:(STPToken *)token
                          completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    NSURL *url = [NSURL URLWithString:@"http://api.daboapp.com/api"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    NSString *body     = [NSString stringWithFormat:@"stripeToken=%@", token.tokenId];
    request.HTTPBody   = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *error) {
                               if (error) {
                                   
                                   completion(PKPaymentAuthorizationStatusFailure);
                                   
                               } else
                               {
                                   
                                   //completion(PKPaymentAuthorizationStatusSuccess);
                                   
                                   [self makePayment_serverWithToken:token.tokenId];
                               }
                           }];
}

- (void)paymentCardTextFieldDidChange:(STPPaymentCardTextField *)textField
{
    // Toggle navigation, for example
    saveButton.enabled = textField.isValid;
}

//- (void)paymentView:(PKView *)view withCard:(PKCard *)card isValid:(BOOL)valid
//{
//    NSLog(@"Vallid card");
////    [payButton setBackgroundColor:[UIColor colorWithRed:0/255.0 green:112/255.0 blue:255/255.0 alpha:1.1]];
//    saveButton.enabled = valid;
//}


#pragma mark - make payment to the server

- (void)makePayment_serverWithToken: (NSString*)tokent
{
    id cartItems = [[NSUserDefaults standardUserDefaults] objectForKey:@"CART"];
    
    NSString *productIdStr = @"";
    if (cartItems) {
        for (int i=0; i<[cartItems count]; i++) {
            NSDictionary *itemDic = [cartItems objectAtIndex:i];
            productIdStr = [productIdStr stringByAppendingString:[NSString stringWithFormat:@"%@,",[itemDic valueForKey:@"id"]]];
                 }
    }
    
    if ([productIdStr length] > 0) {
        productIdStr = [productIdStr substringToIndex:[productIdStr length] - 1];
    }
    
    NSMutableDictionary *parameters =
    [[NSMutableDictionary alloc] initWithDictionary:@{
                                                      AUTH_TOKEN : [[GTAPIClient sharedInstance] getAuthToken],
                                                      PRODUCT_ID_KEY: productIdStr,
                                                      STRIPE_TOKEN_KEY: tokent,
                                                      TRANSACTION_TYPE_KEY:@"stripe"
                                                      }];
    [[GTAPIClient sharedInstance] makePaymentWithParams:parameters withSuccess:^(id responseData) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        alertMsg = [NSString stringWithFormat:@"Successful Payment"];
        
        
        NSLog(@"%@",responseData);
        
        UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"" message:alertMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [theAlert show];
        
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CART"];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
        
//        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
//                                                                 bundle: nil];
//        GTGiftItemsViewController *itemlVC = (GTGiftItemsViewController*)[mainStoryboard
//                                                                          instantiateViewControllerWithIdentifier: @"RECOMMENDED_LIST"];
//        
//        [self.navigationController pushViewController:itemlVC animated:NO];

        
    } failure:^(NSError *er) {
        
        [MBProgressHUD hideAllHUDsForView:self.view
                                 animated:YES];

        [[[UIAlertView alloc] initWithTitle:@""
                                    message:@"An error occured. Please try again."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];

    }];
}

- (void)closeKeyboard:(id)sender
{
  [self.view endEditing:YES];
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
  if (component == 0) {
    selectedMonth = row + 1;
  } else {
    selectedYear = row + 2015;
  }
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
  return 2;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView
    numberOfRowsInComponent:(NSInteger)component {
  // 12 months, 20 years.
  if (component == 0) {
    return 12;
  } else {
    return 20;
  }
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component {
  if (component == 0) {
    return [NSString stringWithFormat:@"%zd", row + 1];
  } else {
    return [NSString stringWithFormat:@"%zd", row + 2015];
  }
}

- (IBAction)openPickerView:(id)sender {
  [pickerView setHidden:!pickerView.hidden];
}

- (IBAction)doneAction:(id)sender {
  [pickerView setHidden:!pickerView.hidden];
  selectedMonth = [pickerControl selectedRowInComponent:0] + 1;
  selectedYear = [pickerControl selectedRowInComponent:1] + 2015;
  expiryTxtField.text =
      [NSString stringWithFormat:@"%lu/%lu", (unsigned long)selectedMonth,
                                 (unsigned long)selectedYear];
}

- (IBAction)clearAction:(id)sender{
    pickerView.hidden=YES;
    expiryTxtField.text=@"";
    
}

#define kLENGTH 4

- (BOOL)textField:(UITextField *)textField
    shouldChangeCharactersInRange:(NSRange)range
                replacementString:(NSString *)string {
  if (textField.tag != 101 && textField.tag != 102) {
    return YES;
  }

  if (textField.tag == 102) {
    NSString *str = [textField.text
        stringByAppendingString:[NSString stringWithFormat:@"%@", string]];
    if (str.length > 3) {
      [textField resignFirstResponder];
      return NO;
    } else {
      return YES;
    }
  }

  if (string.length > 0) {
    NSUInteger length = textField.text.length;
    int cntr = (int)((length - (length / kLENGTH)) / kLENGTH);
    if (!(((length + 1) % kLENGTH) - cntr)) {
      NSString *str = [textField.text
          stringByAppendingString:[NSString stringWithFormat:@"%@ ", string]];
      if (str.length > 20) {
        [textField resignFirstResponder];
        return NO;
      }
      textField.text = str;
      if (textField.text.length >= 19) {
        [textField resignFirstResponder];
      }

      return NO;
    }
  } else {
    if ([textField.text hasSuffix:@" "]) {
      textField.text =
          [textField.text substringToIndex:textField.text.length - 2];
      if (textField.text.length >= 19) {
        [textField resignFirstResponder];
      }
      return NO;
    }
  }

  if (textField.tag == 101) {
    if (textField.text.length >= 19) {
      [textField resignFirstResponder];
      return NO;
    }
  }
  return YES;
}

@end
