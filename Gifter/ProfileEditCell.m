//
//  ProfileEditCell.m
//  Gifter
//
//  Created by Karthik on 22/03/2015.
//
//

#import "ProfileEditCell.h"


@implementation ProfileEditCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        [self updateView];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [self updateView];
}

- (void)updateView
{
    UIColor *borderColor = [UIColor colorWithRed:232.0/255.0 green:0 blue:31.0/255.0 alpha:0.8];
    
    [[_minBudget layer] setBorderColor:borderColor.CGColor];
    [[_maxBudget layer] setBorderColor:borderColor.CGColor];
    
    [[_minBudget layer] setBorderWidth:1.0f];
    [[_maxBudget layer] setBorderWidth:1.0f];

    [[_minBudget layer] setCornerRadius:3.5f];
    [[_maxBudget layer] setCornerRadius:3.5f];

    [_minBudget setTag:301];
    [_maxBudget setTag:302];
}

+ (CGFloat)getHight {
  return 60.0f;
}
+ (NSString *)cellIdentifier {
  return @"PROFILE_EDIT_CELL";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  if (!selected) {
    self.backgroundColor = [UIColor whiteColor];
    self.nameLbl.textColor = [UIColor blackColor];
    self.typeImageView.tintColor = GT_RED;
  } else {
    [UIView animateWithDuration:0.3
                     animations:^{
                       self.backgroundColor = GT_RED;
                       self.nameLbl.textColor = [UIColor whiteColor];
                       self.typeImageView.tintColor = [UIColor whiteColor];
                     }];
  }
}

@end
