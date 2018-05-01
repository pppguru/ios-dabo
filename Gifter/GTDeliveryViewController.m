//
//  GTDeliveryViewController.m
//  Gifter
//
//  Created by Karthik on 22/03/2015.
//
//

#import "GTDeliveryViewController.h"
#import "GTAddressAddViewController.h"
#import "GTAPIClient.h"
#import "KTUtility.h"
#import "CartCell.h"
#import <Stripe/Stripe.h>
#import  "GTGiftItemsViewController.h"
#import <PassKit/PassKit.h>
#import "ApplePayStubs/STPTestPaymentAuthorizationViewController.h"
#import "Constants.h"

@interface GTDeliveryViewController ()<PKPaymentAuthorizationViewControllerDelegate>{
    
    NSString *alertMsg;
}
@property (nonatomic,strong)  PKPaymentAuthorizationViewController *auth;


@property(nonatomic, weak) IBOutlet UILabel *lblDeliveryAddress;
@property(nonatomic, weak) IBOutlet UILabel *lblPersonalInfo;
@property(nonatomic, weak) IBOutlet UILabel *lblOrderInfo;

@property(nonatomic, weak) IBOutlet UITextField *txtStreetAddress;
@property(nonatomic, weak) IBOutlet UITextField *txtCity;
@property(nonatomic, weak) IBOutlet UITextField *txtZip;
@property(nonatomic, weak) IBOutlet UITextField *txtCountry;

@property(nonatomic, weak) IBOutlet UITextField *txtAccount;
@property(nonatomic, weak) IBOutlet UITextField *txtPhoneNumber;
@property(nonatomic, weak) IBOutlet UITextField *txtCard;

@property(nonatomic, weak) IBOutlet UILabel *lblTotalItems;
@property(nonatomic, weak) IBOutlet UILabel *lblTotalPrice;

@end

@implementation GTDeliveryViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.navigationItem.title = NSLocalizedString(@"Checkout", @"");

  [self.navigationItem
      setBackBarButtonItem:[[UIBarButtonItem alloc]
                               initWithTitle:@""
                                       style:UIBarButtonItemStyleDone
                                      target:nil
                                      action:nil]];
  selectedIndex = -1;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self getAllAddress];
  [self setupUI];
}

- (void)setupUI {
//  [KTUtility setButtonUI:self.payAppleBtn];
//  [KTUtility setButtonUI:self.payWithCardbtn];
    
    [KTUtility setRoundedButtonUI:self.payWithCardbtn];
    
    [KTUtility setViewWithBottomBorder:self.lblDeliveryAddress];
    [KTUtility setViewWithBottomBorder:self.lblPersonalInfo];
    [KTUtility setViewWithBottomBorder:self.lblOrderInfo];
    [KTUtility setViewWithBottomBorder:self.lblTotalItems];
    [KTUtility setViewWithBottomBorder:self.lblTotalPrice];
    
    [KTUtility setTextFieldBorders:self.txtStreetAddress withLeftImage:nil];
    [KTUtility setTextFieldBorders:self.txtCity withLeftImage:nil];
    [KTUtility setTextFieldBorders:self.txtZip withLeftImage:nil];
    [KTUtility setTextFieldBorders:self.txtCountry withLeftImage:nil];
    
    [KTUtility setTextFieldBorders:self.txtAccount withLeftImage:[[UIImage imageNamed:@"icon-email"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] withLeftImageColor:GT_LIGHT_DARK];
    [KTUtility setTextFieldBorders:self.txtPhoneNumber withLeftImage:[[UIImage imageNamed:@"icon-phone"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] withLeftImageColor:GT_LIGHT_DARK];
    [KTUtility setTextFieldBorders:self.txtCard withLeftImage:[[UIImage imageNamed:@"icon-card"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] withLeftImageColor:GT_LIGHT_DARK];
}

- (void)getAllAddress {
  [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];

  [[GTAPIClient sharedInstance] getAddresses:^(id responseData) {
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view
                             animated:YES];
    addressList = responseData[@"data"];
    [self.tableView reloadData];
  } failure:^(NSError *er) {
    [[[UIAlertView alloc] initWithTitle:@""
                                message:@"An error occured. Please try again."
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view
                             animated:YES];

  }];
}


#pragma mark - User Interaction
- (IBAction)clickBGButton:(id)sender{
    [self.view endEditing:YES];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
  return addressList.count;
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 0.;//[CartCell getHight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSString *cellIdentifier = [CartCell cellIdentifier];

  CartCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (cell == nil) {
    cell = [[CartCell alloc] initWithStyle:UITableViewCellStyleDefault
                           reuseIdentifier:cellIdentifier];
  }

  NSDictionary *address = addressList[indexPath.row];
  cell.itemNameLbl.text = [NSString
      stringWithFormat:@"%@, %@", address[@"street"], address[@"city"]];
  cell.priceLbl.text = [NSString
      stringWithFormat:@"%@ %@", address[@"country"], address[@"zip"]];

  if (selectedIndex == indexPath.row) {
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
  } else {
    cell.accessoryType = UITableViewCellAccessoryNone;
  }
  return cell;
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  selectedIndex = indexPath.row;
  [self.tableView reloadData];
}

- (IBAction)addAddress:(id)sender {
  [self performSegueWithIdentifier:@"ADD_ADDRESS" sender:nil];
}

#pragma mark - Pay With Card

- (IBAction)openPaymentView:(id)sender {
  if (selectedIndex >= 0) {
    [self performSegueWithIdentifier:@"PAY_CARD_VIEW" sender:nil];
  } else {
    [[[UIAlertView alloc] initWithTitle:@""
                                message:@"Please select an address."
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
  }
}

#pragma mark - Apple Pay

- (IBAction)applePay:(id)sender
{
    PKPaymentRequest *paymentRequest = [Stripe
                                        paymentRequestWithMerchantIdentifier:APPLE_MERCHANT_ID];
    // Configure your request here.
    paymentRequest.paymentSummaryItems = [self californiaShippingMethods];
    
    if ([Stripe canSubmitPaymentRequest:paymentRequest])
    {
        [paymentRequest setRequiredShippingAddressFields:PKAddressFieldPostalAddress];
           self.auth = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:paymentRequest];
      //  STPTestPaymentAuthorizationViewController *auth = [[STPTestPaymentAuthorizationViewController alloc] initWithPaymentRequest:paymentRequest];  // for testing in simulator
        self.auth.delegate = self;
        if (self.auth) {
            [self presentViewController:self.auth animated:YES completion:nil];
        } else {
            NSLog(@"Apple Pay returned a nil PKPaymentAuthorizationViewController - make sure you've configured Apple Pay correctly, as outlined at https://stripe.com/docs/mobile/apple-pay");
        }
        
        NSLog(@"Apple Payment Available");
    } else {
        UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"Apple Payment Not Available" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [theAlert show];
        NSLog(@"Apple Payment Not Available");
        // Show the user your own credit card form (see options 2 or 3)
    }
}

- (NSString *)getTotalAmount
{
    double totalCost = 0.0f;
    
    id cartItems = [[NSUserDefaults standardUserDefaults] objectForKey:@"CART"];
    
    NSMutableArray *items = [[NSMutableArray alloc]init];
    
    if (cartItems)
    {
        [items addObjectsFromArray:cartItems];
    }
    for (NSDictionary *item in items)
    {
        NSString *priceStr = item[@"price"];
        priceStr = [priceStr stringByReplacingOccurrencesOfString:@"$" withString:@""];
        
        double price = [priceStr floatValue];
        
        totalCost += price;
    }
    
    NSString *grandTotal = [NSString stringWithFormat:@"%0.2f", (totalCost + 30.00)];
    
    return grandTotal;
}

- (NSArray *)californiaShippingMethods {
    
    id cartItems = [[NSUserDefaults standardUserDefaults] objectForKey:@"CART"];
    
    NSMutableArray *items = [[NSMutableArray alloc]init];
    
    if (cartItems) {
        
        for (int i=0; i<[cartItems count]; i++) {
            NSDictionary *itemDic = [cartItems objectAtIndex:i];
            
            NSString *priceStr = [itemDic valueForKey:@"price"];
             priceStr = [priceStr stringByReplacingOccurrencesOfString:@"$" withString:@""];
            
            PKPaymentSummaryItem *normalItem =
            [PKPaymentSummaryItem summaryItemWithLabel:[itemDic valueForKey:@"name"] amount:[NSDecimalNumber decimalNumberWithString:priceStr]];
            
            [items addObject:normalItem];
        }
        
        PKPaymentSummaryItem *normalItem =
        [PKPaymentSummaryItem summaryItemWithLabel:@"Tax" amount:[NSDecimalNumber decimalNumberWithString:@"30"]];
         [items addObject:normalItem];
        
        PKPaymentSummaryItem *normalItem1 =
        [PKPaymentSummaryItem summaryItemWithLabel:@"Total amount" amount:[NSDecimalNumber decimalNumberWithString:[self getTotalAmount]]];
        [items addObject:normalItem1];

    }

    return items;
}


//- (NSArray *)summaryItemsForShippingMethod
//{
//    NSDictionary *addsDic = [addressList objectAtIndex:selectedIndex];
//    PKShippingMethod *normalItem =
//     [PKShippingMethod summaryItemWithLabel:@"Product Shiped" amount:[NSDecimalNumber decimalNumberWithString:[self getTotalAmount]]];
//     normalItem.detail = @"3-5 Business Days";
//     normalItem.identifier = normalItem.label;
//    
//   
//    
//    return @[normalItem];
//    
//}


#pragma mark - Apple pay delegate methods

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    /*
     We'll implement this method below in 'Creating a single-use token'.
     Note that we've also been given a block that takes a
     PKPaymentAuthorizationStatus. We'll call this function with either
     PKPaymentAuthorizationStatusSuccess or PKPaymentAuthorizationStatusFailure
     after all of our asynchronous code is finished executing. This is how the
     PKPaymentAuthorizationViewController knows when and how to update its UI.
     */
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self handlePaymentAuthorizationWithPayment:payment completion:completion];
}

- (void)handlePaymentAuthorizationWithPayment:(PKPayment *)payment
                                   completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    [[STPAPIClient sharedClient] createTokenWithPayment:payment
                                             completion:^(STPToken *token, NSError *error) {
                                                 if (error) {
                                                     completion(PKPaymentAuthorizationStatusFailure);
                                                     return;
                                                 }
                                                 /*
                                                  We'll implement this below in "Sending the token to your server".
                                                  Notice that we're passing the completion block through.
                                                  See the above comment in didAuthorizePayment to learn why.
                                                  */
                                                 [self createBackendChargeWithToken:token completion:completion];
                                             }];
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    
//    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
//                                                             bundle: nil];
//    GTGiftItemsViewController *itemlVC = (GTGiftItemsViewController*)[mainStoryboard
//                                                                      instantiateViewControllerWithIdentifier: @"RECOMMENDED_LIST"];
//    
//    [self.navigationController pushViewController:itemlVC animated:NO];

    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
   
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
                               } else {
                                   [self makePayment_serverWithToken:token.tokenId];
                                   completion(PKPaymentAuthorizationStatusSuccess);
                                   
                               }
                           }];
}

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
                                                      TRANSACTION_TYPE_KEY:@"apple"
                                                      }];
    [[GTAPIClient sharedInstance] makePaymentWithParams:parameters withSuccess:^(id responseData) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        alertMsg = [NSString stringWithFormat:@"Successful Payment"];
        
        NSLog(@"%@",responseData);
        
        UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"" message:alertMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [theAlert show];
        
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CART"];
        
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


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
          [self.navigationController popToRootViewControllerAnimated:YES];
    }
}



@end
