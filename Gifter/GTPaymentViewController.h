//
//  GTPaymentViewController.h
//  Gifter
//
//  Created by Karthik on 20/04/2015.
//
//

#import "GTBaseViewController.h"
#import <PassKit/PassKit.h>
//#import "PKView.h"
#import <Stripe/Stripe.h>

@interface GTPaymentViewController : GTBaseViewController {
  IBOutlet __weak UITextField *nameTxtField, *cardTxtField, *expiryTxtField,
      *cvcTxtField;
  IBOutlet __weak UIPickerView *pickerControl;
  IBOutlet __weak UIBarButtonItem *doneButton;
  IBOutlet __weak UIView *pickerView;
  double animatedDistance;
  NSUInteger selectedMonth, selectedYear;
  IBOutlet __weak UIButton *saveButton;
}

-(IBAction)payButtonAction :(id)sender;

@end
