//
//  PeopleCell.m
//  Gifter
//
//  Created by Karthik on 22/03/2015.
//
//

#import "PeopleCell.h"


@implementation PeopleCell

#pragma mark - Cell methods.

- (void)awakeFromNib {
  [self.arrowImageView
      setImage:[[UIImage imageNamed:@"Arrow"]
                   imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
  [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

+ (CGFloat)getHight {
  return 86.0f;
}
+ (NSString *)cellIdentifier {
  return @"LOVED_ONES_CELL";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  if (!selected) {
    self.backgroundColor = [UIColor whiteColor];
    self.nameLbl.textColor = [UIColor blackColor];
    [self.arrowImageView setTintColor:GT_RED];
  } else {
    [UIView animateWithDuration:0.3
                     animations:^{
                       self.backgroundColor = GT_RED;
                       self.nameLbl.textColor = [UIColor whiteColor];
                       [self.arrowImageView setTintColor:[UIColor whiteColor]];
                     }];
  }
}
@end
