//
//  GTItemDetailViewController.m
//  Gifter
//
//  Created by Karthik on 15/04/2015.
//
//

#import "GTItemDetailViewController.h"
#import <UIImageView+AFNetworking.h>
#import "KTUtility.h"
#import "NSString+StringSizeWithFont.h"
#import "GTWebViewController.h"


@interface GTItemDetailViewController ()
{
    NSUInteger index;
  
    IBOutlet UIPageControl *pageControl;
    IBOutlet UITableView   *recommendedTableView;
    
}

@end

@implementation GTItemDetailViewController

-(void)viewDidLayoutSubviews
{
    if ([recommendedTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [recommendedTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([recommendedTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [recommendedTableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

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

- (void)updateUI {
    
    self.itemNameLbl.text = self.itemDetail[@"name"];
    
    NSString *price = self.itemDetail[@"price"];
    
    if (price)
        self.priceLbl.text = price;//[NSString stringWithFormat:@"$%0.2f", [price doubleValue] / 100.0f];
    
    self.title = self.itemDetail[@"name"];
    self.descTV.text = self.itemDetail[@"description"];
    
    NSArray *gallery = self.itemDetail[@"gallery"];
    
    if ([gallery isKindOfClass:[NSArray class]]) {
        
        if (gallery.count == 0)
        {
            pageControl.numberOfPages = 1;
            
            [self.imageView setImageWithURL:[NSURL URLWithString:self.itemDetail[@"image"]]];
        }
    }
    else
    {
        [self.imageView setImageWithURL:[NSURL URLWithString:self.itemDetail[@"image"]]];
        
    }
    
    [KTUtility setButtonUI:self.addToCartButton];
    
    [KTUtility setButtonUI:self.dismissButton];

}

- (void)swipeleft:(UISwipeGestureRecognizer *)gestureRecognizer
{
    NSArray *gallery = self.itemDetail[@"gallery"];
    
    if (![gallery isKindOfClass:[NSArray class]]) {
        return;
    }
    else  if (gallery.count == 0)
    {
        pageControl.numberOfPages = 1;
        
        [self.imageView setImageWithURL:[NSURL URLWithString:self.itemDetail[@"image"]]];
        
        return;
    }
    
    NSUInteger count = [self.itemDetail[@"gallery"] count];
    if (count && (index + 1) < count) {
        index++;
    }
    [self loadImage];
}

- (void)swiperight:(UISwipeGestureRecognizer *)gestureRecognizer
{
    
    NSArray *gallery = self.itemDetail[@"gallery"];
    
    if (![gallery isKindOfClass:[NSArray class]]) {
        return;
    }
    else  if (gallery.count == 0)
    {
        pageControl.numberOfPages = 1;
        
        [self.imageView setImageWithURL:[NSURL URLWithString:self.itemDetail[@"image"]]];
        
        return;
    }
    
    
    //NSUInteger count = [self.itemDetail[@"gallery"] count];
   
    NSInteger newVal = (index - 1);
    if (newVal >= 0) {
        index--;
    }
    [self loadImage];
}

- (void)loadImage
{
  if ([self.itemDetail[@"gallery"] isKindOfClass:[NSArray class]]) {
    NSArray *items = self.itemDetail[@"gallery"];
    if (items.count) {
      pageControl.numberOfPages = items.count;
      pageControl.currentPage = index;
      [UIView animateWithDuration:0.3
          animations:^{
            self.imageView.alpha = 0.0;
          }
          completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3
                animations:^{
                  [self.imageView
                      setImageWithURL:[NSURL
                                          URLWithString:self.itemDetail[
                                                            @"gallery"][index]]];
                  self.imageView.alpha = 1.0f;
                }
                completion:^(BOOL finished){

                }];
          }];
    }
  }
}


- (void)swipeLeft {
    
}


- (IBAction)addToCart:(id)sender
{
   //  [self cart];
    NSString *feed_from             = [self objectOrNilForKey:@"feed_from" fromDictionary:self.itemDetail];
    NSString *landing_page          = [self objectOrNilForKey:@"landing_page" fromDictionary:self.itemDetail];

    
    if ([feed_from isEqual:@"amazon"]) // product is from Amazon, open Amazon page
    {
        if (landing_page) {
            
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            GTWebViewController *vc = (GTWebViewController *)
            [sb instantiateViewControllerWithIdentifier:@"GTWebVC"];
            
            vc.webURL = landing_page;
            
            [self.navigationController pushViewController:vc animated:YES];
            
            //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:landing_page]];

        }
    }
    else // add to cart
    {
        UIAlertView *alertmsg =[[UIAlertView alloc] initWithTitle:@"" message:@"Do you want to add this item into cart ?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [alertmsg show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex ==1) {
         [self cart];
    }
}

- (void)cart
{
    NSString *feed_from             = [self objectOrNilForKey:@"feed_from" fromDictionary:self.itemDetail];
    NSString *landing_page          = [self objectOrNilForKey:@"landing_page" fromDictionary:self.itemDetail];

    id cartItems = [[NSUserDefaults standardUserDefaults] objectForKey:@"CART"];
    NSMutableArray *cartItem = [[NSMutableArray alloc] init];
    if (cartItems) {
        [cartItem addObjectsFromArray:cartItems];
    }
    
    NSString *giftId                = [self objectOrNilForKey:@"product_id" fromDictionary:self.itemDetail];
    NSString *image                 = [self objectOrNilForKey:@"image" fromDictionary:self.itemDetail];
    NSString *manufacturer          = [self objectOrNilForKey:@"manufacturer" fromDictionary:self.itemDetail];
    NSString *name                  = [self objectOrNilForKey:@"name" fromDictionary:self.itemDetail];
    NSString *price                 = [self objectOrNilForKey:@"price" fromDictionary:self.itemDetail];
    
    NSDictionary *updatedDetails = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [self addObjectOrNil:feed_from], @"feed_from",
                                    [self addObjectOrNil:giftId],   @"id",
                                    [self addObjectOrNil:image],    @"image",
                                    [self addObjectOrNil:landing_page], @"landing_page",
                                    [self addObjectOrNil:manufacturer], @"manufacturer",
                                    [self addObjectOrNil:name], @"name",
                                    [self addObjectOrNil:price], @"price",
                                    nil];
    
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


#pragma mark - Table

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger height = 60;
    
    if (indexPath.row == 1) {
        
        NSString *title       = self.itemDetail[@"description"];
        
        CGSize descriptionLableSize = [title sizeWithMyFont:[UIFont systemFontOfSize:15.0f]];
        
        NSUInteger h = descriptionLableSize.height;
        
        h = (h < height) ? height : h;

        return h;
        
    }
    
    return height;
    
    //return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self getCurrentCellForIndex:indexPath inTable:tableView];
    
    if (indexPath.row == 0)
    {
        UILabel *nameLabel   = (UILabel*)[cell.contentView viewWithTag:101];
        UILabel *priceLabel  = (UILabel*)[cell.contentView viewWithTag:102];
        
        NSString *price = self.itemDetail[@"price"];
        
        if (price && ![price isEqual:NULL])
            priceLabel.text = price;//[NSString stringWithFormat:@"$%0.2f", [price doubleValue] / 100.0f];
        
        nameLabel.text = self.itemDetail[@"name"];
    }
    
    else if (indexPath.row == 1)
    {
        cell.textLabel.text = self.itemDetail[@"description"];
    }
    
    else
    {
        UIButton *addToCart = (UIButton *)[cell viewWithTag:23];
        [KTUtility setButtonUI:addToCart];
    }
    
    return cell;
    
    //    NSString *cellIdentifier = [CartCell cellIdentifier];
    //
    //
    //
    //    NSUInteger index = indexPath.row;//(self.items.count > 1) ? indexPath.row + 1 : indexPath.row;
    //
    //    NSDictionary *item = self.items[index];
    //    [cell.imageIconImageView setBackgroundColor:GT_RED];
    //    [[cell.imageIconImageView layer]
    //     setCornerRadius:cell.imageIconImageView.frame.size.width / 2];
    //    [[cell.imageIconImageView layer] setBorderWidth:1.0f];
    //    [[cell.imageIconImageView layer]
    //     setBorderColor:[UIColor colorWithRed:.98 green:.37 blue:.33 alpha:0.5]
    //     .CGColor];
    //    cell.itemNameLbl.text = item[@"name"];
    //
    //    if ([item[@"image"] isKindOfClass:[NSArray class]]) {
    //        NSArray *items = item[@"image"];
    //        if (items.count) {
    //            [cell.imageIconImageView
    //             setImageWithURL:[NSURL URLWithString:item[@"image"][0]]];
    //        }
    //    }
    //    else
    //    {
    //        [cell.imageIconImageView setImageWithURL:[NSURL URLWithString:item[@"image"]]];
    //    }
    //
    //    cell.priceLbl.text = [NSString
    //                          stringWithFormat:@"$%0.2f", [item[@"price"] doubleValue] / 100.0f];
    //    return cell;
}

- (UITableViewCell*)getCurrentCellForIndex:(NSIndexPath*)indexPath inTable:(UITableView*)tableView
{
    NSString *cellIdentifier = nil;
    
    if (indexPath.row == 0) {
        
        cellIdentifier = @"NamePriceCell";
        
    }
    else if (indexPath.row == 1)
    {
        cellIdentifier = @"DescriptionCell";
        
    }
    
    else
        cellIdentifier = @"BuyNowCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    cell.textLabel.numberOfLines = 0;
    
    [cell.textLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [cell.textLabel setTextColor:[UIColor blackColor]];
    
    return cell;
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
