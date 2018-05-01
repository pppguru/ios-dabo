//
//  PeopleCell.h
//  Gifter
//
//  Created by Karthik on 22/03/2015.
//
//

#import <UIKit/UIKit.h>

@interface PeopleCell : UITableViewCell
@property(nonatomic, weak) IBOutlet UILabel *nameLbl;
@property(nonatomic, weak) IBOutlet UIImageView *profileImageView;
@property(nonatomic, weak) IBOutlet UIImageView *arrowImageView;
+ (NSString *)cellIdentifier;
+ (CGFloat)getHight;
@end
