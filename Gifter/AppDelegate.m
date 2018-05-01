//
//  AppDelegate.m
//  Gifter
//
//  Created by Karthik on 21/03/2015.
//
//


#define storyBoard                 [UIStoryboard storyboardWithName:@"Main" bundle:nil]

#import "AppDelegate.h"

#import "GTBaseTabBarViewController.h"

#import <FBSDKCoreKit/FBSDKApplicationDelegate.h>
#import <FBSDKCoreKit/FBSDKAppEvents.h>
#import <AFNetworkActivityIndicatorManager.h>


#import "Stripe.h"

@interface AppDelegate ()


@end

@implementation AppDelegate
@synthesize occasionJsonStr;
@synthesize deviceTokenStr;

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self openSplash];
    
    [self.window makeKeyAndVisible];
    
    [self setupUIElements];
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    [Stripe setDefaultPublishableKey:StripePublishableKey];
    
    [AppDelegate registerUserForPushNotification];
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)openSplash
{
    GTBaseTabBarViewController *tabCtrl = (GTBaseTabBarViewController *)self.window.rootViewController;
    
    UINavigationController *nav = [tabCtrl.viewControllers objectAtIndex:0];
    
    self.lauchView = [storyBoard instantiateViewControllerWithIdentifier:@"LaunchViewController"];
    
    [nav pushViewController:self.lauchView animated:NO];
}

- (void)setupUIElements {
    
    [[UIApplication sharedApplication]
     setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UINavigationBar appearance] setTintColor:GT_DARK];
    [[UINavigationBar appearance] setBarTintColor:GT_NAV_COLOR];
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                           NSForegroundColorAttributeName : GT_DARK,
                                                           NSFontAttributeName : SMART_FROCK(18)
                                                           }];
    
    [[UIBarButtonItem appearance] setTintColor:GT_RED];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{
                                                           NSForegroundColorAttributeName : GT_RED,
                                                           NSFontAttributeName : SKIA_LIGHT(16)
                                                           } forState:UIControlStateNormal];
    
    [[UISegmentedControl appearance] setTitleTextAttributes:@{
                                                              NSForegroundColorAttributeName : GT_RED,
                                                              NSFontAttributeName : SKIA_REGULAR(14)
                                                              } forState:UIControlStateNormal];
    
    [self.window setTintColor:GT_RED];
    
    [[UITabBar appearance] setBarTintColor:Tab_color];
    [[UITabBarItem appearance] setTitleTextAttributes:@{
                                                        NSForegroundColorAttributeName : GT_LIGHT_DARK,
                                                        NSFontAttributeName : SNAPPY_MEDIUM(10)
                                                        } forState:UIControlStateNormal];
    
    [[UITabBar appearance] setTintColor:GT_RED_ANOTHER];
}

#pragma mark Notifications Part

+ (void)registerUserForPushNotification
{
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
}

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    if (notificationSettings.types != UIUserNotificationTypeNone)
    {
        
    }
    //register to receive notifications
    [application registerForRemoteNotifications];
}

#endif

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *deviceTokenString = [NSString stringWithFormat:@"%@", deviceToken];
    deviceTokenString = [deviceTokenString stringByReplacingOccurrencesOfString:@"<" withString:@""];
    deviceTokenString = [deviceTokenString stringByReplacingOccurrencesOfString:@">" withString:@""];
    deviceTokenString = [deviceTokenString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    self.deviceTokenStr = deviceTokenString;
    
  //  [[[UIAlertView alloc] initWithTitle:deviceTokenString message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state.
    // This can occur for certain types of temporary interruptions (such as an
    // incoming phone call or SMS message) or when the user quits the application
    // and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down
    // OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate
    // timers, and store enough application state information to restore your
    // application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called
    // instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state;
    // here you can undo many of the changes made on entering the background.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if
    // appropriate. See also applicationDidEnterBackground:.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    [FBSDKAppEvents activateApp];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

@end
