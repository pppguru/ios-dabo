//
//  GTAccountViewController.h
//  Gifter
//
//  Created by Karthik on 22/03/2015.
//
//

#import <UIKit/UIKit.h>
#import <FDTakeController.h>
#import "GTBaseViewController.h"

@interface GTAccountViewController : GTBaseViewController {
  FDTakeController *takeController;
}
@property(nonatomic, weak) IBOutlet UIImageView *profileImageView;
@property(nonatomic, weak) IBOutlet UITextField *usernameLbl;
@property(nonatomic, weak) IBOutlet UITextField *password;
@property(nonatomic, weak) IBOutlet UITextField *confPassword;
@property(nonatomic, weak) IBOutlet UISwitch *enableNotificationSwitch,
    *promotionNotificationSwitch;
@property(nonatomic, weak) IBOutlet UITableView *tableView;
@end
