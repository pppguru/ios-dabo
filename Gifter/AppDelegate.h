//
//  AppDelegate.h
//  Gifter
//
//  Created by Karthik on 21/03/2015.
//
//

#import <UIKit/UIKit.h>
#import "LaunchViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic,strong) NSString *deviceTokenStr;
@property (strong,nonatomic) LaunchViewController *lauchView;
@property (strong, nonatomic) NSString *occasionJsonStr;


@end

