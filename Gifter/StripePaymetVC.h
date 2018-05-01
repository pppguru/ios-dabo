//
//  StripePaymetVC.h
//  Gifter
//
//  Created by Macwaves on 6/29/15.
//
//

#import <UIKit/UIKit.h>
#import "PKView.h"

@interface StripePaymetVC : UIViewController<PKViewDelegate>{
    
 IBOutlet UIButton   *payButton;
    
}

@property(weak, nonatomic) IBOutlet PKView *paymentView;

-(IBAction)payButtonAction :(id)sender;

@end
