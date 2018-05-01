//
//  ProfileEditCell.h
//  Gifter
//
//  Created by Karthik on 22/03/2015.
//
//

#import <UIKit/UIKit.h>

@interface ProfileEditCell : UITableViewCell
@property(nonatomic, weak) IBOutlet UILabel *nameLbl;
@property(nonatomic, weak) IBOutlet UILabel *selectionLbl;
@property(nonatomic, weak) IBOutlet UIImageView *typeImageView;

@property(nonatomic, weak) IBOutlet UITextField *minBudget;
@property(nonatomic, weak) IBOutlet UITextField *maxBudget;


+ (NSString *)cellIdentifier;
+ (CGFloat)getHight;

@end
