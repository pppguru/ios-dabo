//
//  GTRecommendedViewController.m
//  Gifter
//
//  Created by Karthik on 14/04/2015.
//
//

#import "GTGiftItemsViewController.h"
#import "CartCell.h"
#import "GTAPIClient.h"
#import <UIImageView+AFNetworking.h>
#import "GTItemDetailViewController.h"
#import "GTRecommendedGiftVC.h"
#import "GTWebViewController.h"

#import "KTUtility.h"

@interface GTGiftItemsViewController ()
@property(nonatomic, strong) NSArray *items;
@property(nonatomic, strong) NSArray *recommendedItems;

@property(nonatomic, weak) IBOutlet UITableView *tableView;
@property(nonatomic, strong) IBOutlet UIButton *recommendedBtn;

@property (nonatomic, strong) UIImage *blurBackground;

@property (nonatomic, assign) BOOL visible;

@end

@implementation GTGiftItemsViewController

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
        self.visible = false;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.visible = true;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.title = NSLocalizedString(@"Gifts", @"");
  
    [self loadContent];
    
    //[self.recommendedBtn setAlpha:0.8];
    [self.recommendedBtn setUserInteractionEnabled:FALSE];
    
  [self.navigationItem
      setBackBarButtonItem:[[UIBarButtonItem alloc]
                               initWithTitle:@""
                                       style:UIBarButtonItemStyleDone
                                      target:nil
                                      action:nil]];

  [self.navigationItem
      setLeftBarButtonItem:[[UIBarButtonItem alloc]
                               initWithTitle:@"Cancel"
                                       style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(cancelAction)]];
   
  [KTUtility setButtonUI:self.recommendedBtn];

  //  if (self.items.count < 1) {
  //    [[self.tableView tableHeaderView] removeFromSuperview];
  //  }

  // Do any additional setup after loading the view.
}



- (void)cancelAction {
  [[[UIAlertView alloc] initWithTitle:@""
                              message:@"Are you sure you want to cancel?"
                             delegate:self
                    cancelButtonTitle:@"No"
                    otherButtonTitles:@"Yes", nil] show];
}

- (void)alertView:(UIAlertView *)alertView
    clickedButtonAtIndex:(NSInteger)buttonIndex {
  if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Yes"]) {
    [self cancelOrder];
  }
    
  else{
      
      switch (buttonIndex) {
          case 0:
              NSLog(@"%@", @"Button Cancel Pressed");
              break;
          case 1:
              NSLog(@"%@", @"Button Retry Pressed");
              [self loadContent];
              break;
              
          default:
              break;
              
      }
 
      
  }
}

- (void)cancelOrder {
  /* NOTIFY(@"CLEAR_CART", nil);
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CART"];
  [[NSUserDefaults standardUserDefaults] synchronize];

  UIViewController *vc =
      self.navigationController.tabBarController.viewControllers[3];
  [[vc tabBarItem] setBadgeValue:nil];

   */
  [self.navigationController popToRootViewControllerAnimated:YES];
  
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}


- (void)loadContent {
    
    //[MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    hud.labelText = @"Feels good to Dabo";
    
    [[GTAPIClient sharedInstance] fetchAllGifts:self.params
                                        success:^(NSArray *items)
    {
                                            [MBProgressHUD hideAllHUDsForView:self.navigationController.view
                                                                     animated:YES];
                                            
                                            self.items = items;
                                            
                                            [self.tableView reloadData];
                                            
                                           [self loadRecommendedProducts];
                                            
                                            //        if (items.count > 1) {
                                            
                                            //        }
                                            //        else {
                                            //          [self.tableView setTableHeaderView:nil];
                                            //        }
                                            
                                        }
                                        failure:^(NSError *er) {
                                            [MBProgressHUD hideAllHUDsForView:self.navigationController.view
                                                                     animated:YES];
                                            
                                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Data Found"
                                                                                                message:nil
                                                                                               delegate:self
                                                                                      cancelButtonTitle:@"Cancel"
                                                                                      otherButtonTitles:@"Retry", nil];
                                            [alertView show];
                                            [self loadRecommendedProducts];

                                        }];
}


-(IBAction)refreshButton:(id)sender{
    
    [self loadContent];
}



- (void)loadRecommendedProducts {
    
    [[GTAPIClient sharedInstance] fetchRecommendations:self.params
                                               success:^(NSArray *items) {
                                                
                                                   self.recommendedItems = items;
                                                   
                                                   if (items.count > 1) {
                                                       [self openRecommended:self.recommendedBtn];
                                                   }
                                                   
                                                   [self.recommendedBtn setAlpha:1.0];
                                                   [self.recommendedBtn setUserInteractionEnabled:TRUE];
                                                   
                                                   [MBProgressHUD hideAllHUDsForView:self.navigationController.view
                                                                            animated:YES];

                                                   
                                               }
                                               failure:^(NSError *er) {
                                                   
                                                   [self.recommendedBtn setAlpha:1.0];
                                                   [self.recommendedBtn setUserInteractionEnabled:TRUE];
                                                   
                                                   [MBProgressHUD hideAllHUDsForView:self.navigationController.view
                                                                            animated:YES];

                                               }];
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!self.items.count) {
        tableView.tableFooterView.hidden = YES;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
     return self.items.count;
    
    //return self.items.count > 1 ? self.items.count - 1 : self.items.count;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [CartCell getHight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [CartCell cellIdentifier];
    
    CartCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[CartCell alloc] initWithStyle:UITableViewCellStyleDefault
                               reuseIdentifier:cellIdentifier];
    }
    
    NSUInteger index = indexPath.row;//(self.items.count > 1) ? indexPath.row + 1 : indexPath.row;
    
    NSDictionary *item = self.items[index];
    [cell.imageIconImageView setBackgroundColor:GT_RED];
    [[cell.imageIconImageView layer]
     setCornerRadius:cell.imageIconImageView.frame.size.width / 2];
    [[cell.imageIconImageView layer] setBorderWidth:1.0f];
    [[cell.imageIconImageView layer]
     setBorderColor:[UIColor colorWithRed:.98 green:.37 blue:.33 alpha:0.5]
     .CGColor];
    cell.itemNameLbl.text = item[@"name"];
    
    if ([item[@"image"] isKindOfClass:[NSArray class]]) {
        NSArray *items = item[@"image"];
        if (items.count) {
            [cell.imageIconImageView
             setImageWithURL:[NSURL URLWithString:item[@"image"][0]]];
        }
    }
    else
    {
        [cell.imageIconImageView setImageWithURL:[NSURL URLWithString:item[@"image"]]];
    }
    
    NSString *price = item[@"price"];
    
    if (price)
        cell.priceLbl.text = price;//[NSString stringWithFormat:@"$%0.2f", [price doubleValue] / 100.0f];
    
    else
        cell.priceLbl.text = @"";
    
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSUInteger index = indexPath.row;//(self.items.count > 1) ? indexPath.row + 1 : indexPath.row;
    [self performSegueWithIdentifier:@"SHOW_ITEM" sender:@(index)];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    GTItemDetailViewController *destination = segue.destinationViewController;
    destination.itemDetail = self.items[[sender integerValue]];
    
}

- (IBAction)openRecommended:(id)sender
{
    if (self.visible) {
        
        if (self.recommendedItems && self.recommendedItems.count)
        {
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            GTRecommendedGiftVC *vc = (GTRecommendedGiftVC *)
            [sb instantiateViewControllerWithIdentifier:@"ITEM_MODAL"];
            
            vc.backgroundImage = [self generateBlurredImageForView];
            
            if (self.recommendedItems && self.recommendedItems.count > 3) {
                
                NSMutableArray *newArray = [NSMutableArray new];
                
                for ( int i = 0 ; i < 3; ++i) {
                    
                    NSDictionary *data = [self.recommendedItems objectAtIndex:i];
                    
                    [newArray addObject:data];
                }
                
                vc.recommendedItems = newArray;
            }
            else
                vc.recommendedItems = self.recommendedItems;
            
            vc.giftItemController = self;
            
            [self.navigationController presentViewController:vc
                                                    animated:YES
                                                  completion:^{
                                                      
                                                  }];
        }
        
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"No recommendation found" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            
            [alertView show];
        }
        //http://giftedapp.advancode.co/api/gift/get-recommended
    }
}

- (void)openAmazonForURL:(NSString*)url
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    GTWebViewController *vc = (GTWebViewController *)
    [sb instantiateViewControllerWithIdentifier:@"GTWebVC"];
    
    vc.webURL = url;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (UIImage *)generateBlurredImageForView {
    
    @try {
        UIImage *image = [self takeSnapshotOfView:self.view];
        if (image) {
            UIImage *imageRef = [self blurWithCoreImage:image];
            return imageRef;
        }
        return nil;
    }
    @catch (NSException *exception) {
        return nil;
    }

}

- (UIImage *)takeSnapshotOfView:(UIView *)view {
  UIGraphicsBeginImageContext(
      CGSizeMake(view.frame.size.width, view.frame.size.height));
  [view drawViewHierarchyInRect:CGRectMake(0, 0, view.frame.size.width,
                                           view.frame.size.height)
             afterScreenUpdates:YES];
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  return image;
}

- (UIImage *)blurWithCoreImage:(UIImage *)sourceImage {
  CIImage *inputImage = [CIImage imageWithCGImage:sourceImage.CGImage];

  CGAffineTransform transform = CGAffineTransformIdentity;
  CIFilter *clampFilter = [CIFilter filterWithName:@"CIAffineClamp"];
  [clampFilter setValue:inputImage forKey:@"inputImage"];
  [clampFilter setValue:[NSValue valueWithBytes:&transform
                                       objCType:@encode(CGAffineTransform)]
                 forKey:@"inputTransform"];

  CIFilter *gaussianBlurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
  [gaussianBlurFilter setValue:clampFilter.outputImage forKey:@"inputImage"];
  [gaussianBlurFilter setValue:@15 forKey:@"inputRadius"];

  CIContext *context = [CIContext contextWithOptions:nil];
  CGImageRef cgImage = [context createCGImage:gaussianBlurFilter.outputImage
                                     fromRect:[inputImage extent]];

  UIGraphicsBeginImageContext(self.view.frame.size);
  CGContextRef outputContext = UIGraphicsGetCurrentContext();
  CGContextScaleCTM(outputContext, 1.0, -1.0);
  CGContextTranslateCTM(outputContext, 0, -self.view.frame.size.height);
  CGContextDrawImage(outputContext, self.view.frame, cgImage);
  CGContextSaveGState(outputContext);
  CGContextSetFillColorWithColor(outputContext,
                                 [UIColor colorWithWhite:1 alpha:0.2].CGColor);
  CGContextFillRect(outputContext, self.view.frame);
  CGContextRestoreGState(outputContext);

  if (cgImage) {
    CFRelease(cgImage);
  }

  UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  return outputImage;
}

@end
