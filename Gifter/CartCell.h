//
//  CartCell.h
//  Gifter
//
//  Created by Karthik on 22/03/2015.
//
//

#import <UIKit/UIKit.h>

@interface CartCell : UITableViewCell
@property(nonatomic, weak) IBOutlet UILabel *itemNameLbl, *priceLbl, *countLbl;
@property(nonatomic, weak) IBOutlet UIImageView *imageIconImageView;

+ (NSString *)cellIdentifier;
+ (CGFloat)getHight;
@end
