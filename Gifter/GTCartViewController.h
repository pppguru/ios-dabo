//
//  GTCartViewController.h
//  Gifter
//
//  Created by Karthik on 22/03/2015.
//
//

#import <UIKit/UIKit.h>

@interface GTCartViewController : UIViewController <UITableViewDelegate>{
  NSMutableArray *items;
  NSMutableDictionary *sortedItems;
  NSMutableDictionary *itemCount;
}
@property(nonatomic, weak) IBOutlet UIButton *continueBtn;
@property(nonatomic, weak) IBOutlet UITableView *tableView;
@property(nonatomic, weak) IBOutlet UILabel *totalPriceLbl, *taxPriceLbl, *totalCountlbl,
    *grandTotalLbl;
@end
