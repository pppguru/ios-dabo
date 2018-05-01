//
//  GTRecommendedGiftVC.h
//  Gifter
//
//  Created by Muzammil Mohammad on 04/06/15.
//
//

#import <UIKit/UIKit.h>

@class GTGiftItemsViewController;

@interface GTRecommendedGiftVC : UIViewController

@property(nonatomic, strong) NSArray *recommendedItems;

@property(nonatomic, strong) IBOutlet UILabel *itemNameLbl;
@property(nonatomic, strong) UIImage *backgroundImage;
@property(nonatomic, strong) IBOutlet UIImageView *imageView;
@property(nonatomic, strong) IBOutlet UILabel *priceLbl;
@property(nonatomic, strong) IBOutlet UITextView *descTV;
@property(nonatomic, strong) IBOutlet UIButton *addToCartButton;
@property(nonatomic, strong) IBOutlet UIButton *dismissButton;
@property(nonatomic,strong) IBOutlet UIImageView *lovedoneImage;
@property(nonatomic,strong) IBOutlet UILabel *Name;

@property (nonatomic, weak) IBOutlet UIView *backView;

@property (nonatomic, retain) GTGiftItemsViewController *giftItemController;

@end
