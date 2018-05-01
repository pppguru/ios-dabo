//
//  GTBaseViewController.m
//  Gifter
//
//  Created by Karthik on 23/03/2015.
//
//

#import "GTBaseViewController.h"

@implementation GTBaseViewController
#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
    CGRect textFieldRect =
        [self.view.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect =
        [self.view.window convertRect:self.view.bounds fromView:self.view];

    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator = midline - viewRect.origin.y -
                        MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) *
                          viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;

    if (heightFraction < 0.0) {
      heightFraction = 0.0;
    } else if (heightFraction > 1.0) {
      heightFraction = 1.0;
    }

    UIInterfaceOrientation orientation =
        [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait) {
      self.animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    } else {
      self.animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }

    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= self.animatedDistance;

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];

    [self.view setFrame:viewFrame];

    [UIView commitAnimations];
  }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += self.animatedDistance;

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];

    [self.view setFrame:viewFrame];

    [UIView commitAnimations];
  }
}
@end
