//
//  GTRecommendedViewController.h
//  Gifter
//
//  Created by Karthik on 14/04/2015.
//
//

#import <UIKit/UIKit.h>

@interface GTGiftItemsViewController : UIViewController
@property (nonatomic, strong) NSDictionary *params;

- (void)openAmazonForURL:(NSString*)url;
-(IBAction)refreshButton:(id)sender;

@end
