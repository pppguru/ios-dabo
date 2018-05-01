//
//  GTBaseTabBarViewController.m
//  Gifter
//
//  Created by Karthik on 22/03/2015.
//
//

#import "GTBaseTabBarViewController.h"

@interface UIImage (Overlay)
@end

@implementation UIImage (Overlay)

- (UIImage *)imageWithColor:(UIColor *)color1 {
  UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextTranslateCTM(context, 0, self.size.height);
  CGContextScaleCTM(context, 1.0, -1.0);
  CGContextSetBlendMode(context, kCGBlendModeNormal);
  CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
  CGContextClipToMask(context, rect, self.CGImage);
  [color1 setFill];
  CGContextFillRect(context, rect);
  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return newImage;
}
@end

@implementation GTBaseTabBarViewController

- (void)awakeFromNib {
    [self.tabBar setTintColor:[UIColor whiteColor]];
    [[UITabBarItem appearance]
      setTitleTextAttributes:
          [NSDictionary
              dictionaryWithObjectsAndKeys:GT_RED_ANOTHER,
                                           NSForegroundColorAttributeName, nil]
                    forState:UIControlStateSelected];

    UIColor *unselectedColor = GT_LIGHT_DARK;

    // set color of unselected text
    [[UITabBarItem appearance]
      setTitleTextAttributes:
          [NSDictionary
              dictionaryWithObjectsAndKeys:unselectedColor,
                                           NSForegroundColorAttributeName, nil]
                    forState:UIControlStateNormal];

    // generate a tinted unselected image based on image passed via the storyboard
    for (UITabBarItem *item in self.tabBar.items) {
        if (item.title == nil || item.title.length == 0){
            item.image = [[item.selectedImage imageWithColor:GT_RED_ANOTHER]
                          imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        }
        else
        {
            // use the UIImage category code for the imageWithColor: method
            item.image = [[item.selectedImage imageWithColor:unselectedColor]
                          imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        }
    }
    self.delegate = self;
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController
    shouldSelectViewController:(UIViewController *)viewController {
  NSUInteger indexOfNewViewController =
      [tabBarController.viewControllers indexOfObject:viewController];
  // Only the second tab shouldn't pop home
  return ((indexOfNewViewController != 0) ||
          (indexOfNewViewController != tabBarController.selectedIndex));
}

@end
