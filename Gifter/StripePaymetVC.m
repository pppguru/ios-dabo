//
//  StripePaymetVC.m
//  Gifter
//
//  Created by Macwaves on 6/29/15.
//
//

#import "StripePaymetVC.h"
#import "PKView.h"
#import "Stripe.h"

@interface StripePaymetVC ()

@end

@implementation StripePaymetVC

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
     //_paymentView =[[PKView alloc] init];
    [self.view addSubview:_paymentView];
    self.paymentView.delegate = self;
    payButton.enabled=NO;
    [payButton setBackgroundColor:[UIColor colorWithRed:0/255.0 green:112/255.0 blue:255/255.0 alpha:0.5]];
    payButton.layer.cornerRadius = 5.0f;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)paymentView:(PKView *)view withCard:(PKCard *)card isValid:(BOOL)valid
{
    NSLog(@"Vallid card");
    [payButton setBackgroundColor:[UIColor colorWithRed:0/255.0 green:112/255.0 blue:255/255.0 alpha:1.1]];
    payButton.enabled = valid;
}


-(IBAction)payButtonAction :(id)sender{
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    STPCard *card = [[STPCard alloc] init];
    card.number = self.paymentView.card.number;
    card.expMonth = self.paymentView.card.expMonth;
    card.expYear = self.paymentView.card.expYear;
    card.cvc = self.paymentView.card.cvc;
    [Stripe createTokenWithCard:card completion:^(STPToken *token, NSError *error) {
        NSString *alertMsg;
        if (error)
        {
            alertMsg = [NSString stringWithFormat:@"Invalid Card Detail"];
            NSLog(@"%@",error);
            
        } else
        {
            
            alertMsg = [NSString stringWithFormat:@"Successful Payment"];
            NSLog(@"%@",token);
            
        }
        
        UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"" message:alertMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [theAlert show];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
    }];
    
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
