//
//  ChangePasswordViewController.h
//  Gifter
//
//  Created by Macwaves on 9/2/15.
//
//

#import <UIKit/UIKit.h>
#import <FDTakeController.h>

@interface ChangePasswordViewController : UIViewController<UITextFieldDelegate>
@property(nonatomic,weak) IBOutlet UITextField *changePass;
@property(nonatomic,weak) IBOutlet UITextField *confirmPass;

@property (nonatomic,retain) NSString *userName;
-(IBAction)save:(id)sender;


@end
