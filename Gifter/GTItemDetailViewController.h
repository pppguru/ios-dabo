//
//  GTItemDetailViewController.h
//  Gifter
//
//  Created by Karthik on 15/04/2015.
//
//

#import <UIKit/UIKit.h>

@interface GTItemDetailViewController : UIViewController
    
@property(nonatomic, strong) NSDictionary *itemDetail;
@property(nonatomic, strong) IBOutlet UILabel *itemNameLbl;
@property(nonatomic, strong) UIImage *backgroundImage;
@property(nonatomic, strong) IBOutlet UIImageView *imageView;
@property(nonatomic, strong) IBOutlet UILabel *priceLbl;
@property(nonatomic, strong) IBOutlet UITextView *descTV;
@property(nonatomic, weak) IBOutlet UIButton *addToCartButton;
@property(nonatomic, strong) IBOutlet UIButton *dismissButton;
@end
