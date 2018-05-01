//
//  GTDeliveryViewController.h
//  Gifter
//
//  Created by Karthik on 22/03/2015.
//
//

#import <UIKit/UIKit.h>

@interface GTDeliveryViewController : UIViewController {
  NSArray *addressList;
  NSInteger selectedIndex;
}
@property(nonatomic, weak) IBOutlet UITableView *tableView;
@property(nonatomic, weak) IBOutlet UIButton *payWithCardbtn, *payAppleBtn;
@end
