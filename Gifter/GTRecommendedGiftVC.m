//
//  GTRecommendedGiftVC.m
//  Gifter
//
//  Created by Muzammil Mohammad on 04/06/15.
//
//

#import "GTRecommendedGiftVC.h"
#import "GTWebViewController.h"
#import "GTGiftItemsViewController.h"

#import <UIImageView+AFNetworking.h>
#import "KTUtility.h"

@interface GTRecommendedGiftVC () {

    NSUInteger index;
    IBOutlet UIPageControl *pageControl;
}

@end

@implementation GTRecommendedGiftVC

@synthesize giftItemController = _giftItemController;

- (void)viewDidLoad

{
    [super viewDidLoad];
    
    [self updateUI];
    index = 0;
    
    UISwipeGestureRecognizer *swipeleft =
    [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                              action:@selector(swipeleft:)];
    swipeleft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.imageView addGestureRecognizer:swipeleft];
    
    UISwipeGestureRecognizer *swiperight =
    [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                              action:@selector(swiperight:)];
    swiperight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.imageView addGestureRecognizer:swiperight];
    [self loadImage];
    
    [pageControl setPageIndicatorTintColor:GT_LIGHT_RED];
    [pageControl setCurrentPageIndicatorTintColor:GT_RED];
    
    if (self.backgroundImage) {
        [self addBackgroundImage];
    }
    // Do any additional setup after loading the view.
}

- (IBAction)closeView:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:^{
                                                          
                                                      }];
}

- (void)addBackgroundImage {
    UIImageView *view = [[UIImageView alloc] initWithFrame:self.view.bounds];
    view.image = self.backgroundImage;
    [self.view addSubview:view];
    [self.view sendSubviewToBack:view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateUI
{
    pageControl.numberOfPages = self.recommendedItems.count;
    pageControl.currentPage = index;
    
    NSDictionary *itemDetail = [self.recommendedItems objectAtIndex:index];
    
    self.itemNameLbl.text = itemDetail[@"name"];
    
    NSString *price = itemDetail[@"price"];
    
    if (price)
        self.priceLbl.text = price;//[NSString stringWithFormat:@"$%0.2f", [price doubleValue] / 100.0f];
    
    self.lovedoneImage.layer.cornerRadius = self.lovedoneImage.frame.size.width / 2.0;
    self.lovedoneImage.layer.borderWidth = 1.0f;
    UIColor *borderColor = [UIColor colorWithRed:232.0/255.0 green:0 blue:31.0/255.0 alpha:0.8];
    self.lovedoneImage.layer.borderColor = borderColor.CGColor;
    self.lovedoneImage.clipsToBounds = YES;
    
    //self.title = itemDetail[@"name"];
    //self.descTV.text = itemDetail[@"description"];
    NSUserDefaults *userDefaultValue=[NSUserDefaults standardUserDefaults];
    NSString *imageString = [userDefaultValue valueForKey:@"LovedOneImage"];
    if ([userDefaultValue valueForKey:@"Name"]) {
        self.Name.text = [userDefaultValue valueForKey:@"Name"];
         [self.lovedoneImage setImageWithURL:[NSURL URLWithString:imageString]];
    }
    
    else{
        self.lovedoneImage.hidden=YES;
        self.Name.text =[userDefaultValue valueForKey:@"NewPerson"];
    }
    
    [KTUtility setButtonUI:self.addToCartButton];
    [KTUtility setButtonUI:self.dismissButton];
   
}

- (void)swipeleft:(UISwipeGestureRecognizer *)gestureRecognizer
{
    if (self.recommendedItems && ![self.recommendedItems isEqual:[NSNull null]]) {
        
        NSUInteger count = [self.recommendedItems count];
        
        if (count && (index + 1) < count) {
            
            index++;
            [self loadImage];
            
        }
    }
}

- (void)swiperight:(UISwipeGestureRecognizer *)gestureRecognizer
{
    if (self.recommendedItems && ![self.recommendedItems isEqual:[NSNull null]]) {

        NSUInteger count = [self.recommendedItems count];
        
        NSInteger newVal = (index - 1);
        
        if (count && newVal >= 0) {
            
            index--;
            
            [self loadImage];
        }
    }
}

- (void)loadImage {
    
    [self.imageView setImage:nil];
    
    NSDictionary *itemDetail = [self.recommendedItems objectAtIndex:index];
    
    [self.imageView setImageWithURL:[NSURL URLWithString:itemDetail[@"image"]]];
    
    pageControl.currentPage = index;
    
    self.itemNameLbl.text = itemDetail[@"name"];
    
    NSString *price = itemDetail[@"price"];
    
    if (price)
        self.priceLbl.text = price;//[NSString stringWithFormat:@"$%0.2f", [price doubleValue] / 100.0f];
    
//    self.priceLbl.text = [NSString
//                          stringWithFormat:@"$%0.2f",
//                          [itemDetail[@"price"] doubleValue] / 100.0f];
    
    
    //    if ([itemDetail[@"gallery"] isKindOfClass:[NSArray class]]) {
    //
    //        NSArray *items = itemDetail[@"gallery"];
    //
    //        if (items.count) {
    //
    //
    //            [UIView animateWithDuration:0.3
    //                             animations:^{
    //                                 self.imageView.alpha = 0.0;
    //                             }
    //                             completion:^(BOOL finished) {
    //                                 [UIView animateWithDuration:0.3
    //                                                  animations:^{
    //                                                      [self.imageView
    //                                                       setImageWithURL:[NSURL
    //                                                                        URLWithString:itemDetail[
    //                                                                                                      @"gallery"][index]]];
    //                                                      self.imageView.alpha = 1.0f;
    //                                                  }
    //                                                  completion:^(BOOL finished){
    //
    //                                                  }];
    //                             }];
    //        }
    //    }
}

- (void)swipeLeft {
}

- (IBAction)addToCart:(id)sender
{
    NSDictionary *itemDetail = [self.recommendedItems objectAtIndex:index];
    
    
    NSString *feed_from             = [self objectOrNilForKey:@"feed_from" fromDictionary:itemDetail];
    
    NSString *landing_page          = [self objectOrNilForKey:@"landing_page" fromDictionary:itemDetail];
    
    
    if ([feed_from isEqual:@"amazon"]) // product is from Amazon, open Amazon page
    {
        if (landing_page) {
            
            [self.presentingViewController dismissViewControllerAnimated:YES
                                                              completion:^{
                                                                  
                                                                  [_giftItemController openAmazonForURL:landing_page];
                                                                  
                                                              }];
            
        // [[UIApplication sharedApplication] openURL:[NSURL URLWithString:landing_page]];
        }
    }
    else
    {
        NSString *giftId                = [self objectOrNilForKey:@"product_id" fromDictionary:itemDetail];
        NSString *image                 = [self objectOrNilForKey:@"image" fromDictionary:itemDetail];
        NSString *manufacturer          = [self objectOrNilForKey:@"manufacturer" fromDictionary:itemDetail];
        NSString *name                  = [self objectOrNilForKey:@"name" fromDictionary:itemDetail];
        NSString *price                 = [self objectOrNilForKey:@"price" fromDictionary:itemDetail];
        
        NSDictionary *updatedDetails = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [self addObjectOrNil:feed_from], @"feed_from",
                                        [self addObjectOrNil:giftId],   @"id",
                                        [self addObjectOrNil:image],    @"image",
                                        [self addObjectOrNil:landing_page], @"landing_page",
                                        [self addObjectOrNil:manufacturer], @"manufacturer",
                                        [self addObjectOrNil:name], @"name",
                                        [self addObjectOrNil:price], @"price",
                                        nil];
        
        id cartItems = [[NSUserDefaults standardUserDefaults] objectForKey:@"CART"];
        
        NSMutableArray *cartItem = [[NSMutableArray alloc] init];
        
        if (cartItems) {
            [cartItem addObjectsFromArray:cartItems];
        }
        
        [cartItem addObject:updatedDetails];
        
        [[NSUserDefaults standardUserDefaults] setObject:cartItem forKey:@"CART"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        UIViewController *vc =
        self.navigationController.tabBarController.viewControllers[3];
        [[vc tabBarItem]
         setBadgeValue:[NSString stringWithFormat:@"%ld", (unsigned long)[cartItem count]]];
        NOTIFY(@"CART_UPDATED", nil);
        
        if (self.backgroundImage) {
            [(UITabBarController *)self.presentingViewController setSelectedIndex:3];
            [self.presentingViewController dismissViewControllerAnimated:YES
                                                              completion:^{
                                                                  
                                                              }];
        }
    }
}

#pragma mark - Helper Method

- (id)addObjectOrNil:(id)object{
    
    if (object) {
        return object;
    }
    else
        return @"";
}

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict
{
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}


@end
