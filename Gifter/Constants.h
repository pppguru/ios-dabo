//
//  Constants.h
//  Gifter
//
//  Created by Karthik on 22/03/2015.
//
//

#ifndef Gifter_Constants_h
#define Gifter_Constants_h

static CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

/**
 * Device and OS Macros.
 *
 */
#define SYSTEM_VERSION_EQUAL_TO(v)                                       \
  ([[[UIDevice currentDevice] systemVersion] compare:v                   \
                                             options:NSNumericSearch] == \
   NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)                                   \
  ([[[UIDevice currentDevice] systemVersion] compare:v                   \
                                             options:NSNumericSearch] == \
   NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)                       \
  ([[[UIDevice currentDevice] systemVersion] compare:v                   \
                                             options:NSNumericSearch] != \
   NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                                      \
  ([[[UIDevice currentDevice] systemVersion] compare:v                   \
                                             options:NSNumericSearch] == \
   NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)                          \
  ([[[UIDevice currentDevice] systemVersion] compare:v                   \
                                             options:NSNumericSearch] != \
   NSOrderedDescending)
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 \
  (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0)
#define IS_IPHONE_4 \
  (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 480.0)
#define IS_IPHONE_6 \
  (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0)
#define IS_IPHONE_6P \
  (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 736.0)
#define IS_RETINA ([[UIScreen mainScreen] scale] == 2.0)
#define ScreenBound ([[UIScreen mainScreen] bounds])
#define ScreenHeight (ScreenBound.size.height)
#define ScreenWidth (ScreenBound.size.width)


// sending keys into user/make-purchase api
#define AUTH_TOKEN              @"auth_token"
#define PRODUCT_ID_KEY          @"product_id"
#define STRIPE_TOKEN_KEY        @"token"
#define TRANSACTION_TYPE_KEY    @"transaction_type"



 #define StripeTest_Key            @"pk_test_ds72MJJZR9yFjPEe95NRY0PF"
 #define StripePublishableKey      @"pk_live_Ogwq4JXmWnW0S341wnFRgzGE"

#define  APPLE_MERCHANT_ID         @""
/**
 * Fonts for the application
 */

#define SNAPPY_MEDIUM(s) [UIFont fontWithName:@"HelveticaNeue-Medium" size:s]
#define SKIA_REGULAR(s) [UIFont fontWithName:@"HelveticaNeue-Medium" size:s]
#define SKIA_LIGHT(s) [UIFont fontWithName:@"HelveticaNeue-Medium" size:s]
#define SMART_FROCK(s) [UIFont fontWithName:@"HelveticaNeue-Light" size:s]

#define GT_RED [UIColor colorWithRed:184/255.0 green:32/255.0 blue:32/255.0 alpha:1.0]
#define GT_DARK [UIColor colorWithRed:74./255.0 green:74./255.0 blue:74./255.0 alpha:1.0]
#define GT_LIGHT_DARK [UIColor colorWithRed:155./255. green:155./255. blue:155./255. alpha:1.0]
#define GT_RED_ANOTHER [UIColor colorWithRed:215./255.0 green:42./255.0 blue:62./255.0 alpha:1.0]
#define Tab_color [UIColor whiteColor]//[UIColor colorWithRed:.72156863 green:.1254902 blue:.1254902 alpha:1.0]
#define GT_LIGHT_RED [UIColor colorWithRed:.98 green:.37 blue:.33 alpha:1.0]
#define GT_NAV_COLOR [UIColor whiteColor]

#ifdef DEBUG
#define NSLog(fmt, ...)                                               \
  NSLog((@"Func: %s, Line: %d, " fmt), __PRETTY_FUNCTION__, __LINE__, \
        ##__VA_ARGS__);
#else
#define NSLog(...)
#endif

#define NSProductionLog(fmt, ...)                                     \
  NSLog((@"Func: %s, Line: %d, " fmt), __PRETTY_FUNCTION__, __LINE__, \
        ##__VA_ARGS__);

#define NOTIFY(_name, _object)                                     \
  [[NSNotificationCenter defaultCenter] postNotificationName:_name \
                                                      object:_object]
#define REGISTER_NOTIFY(_observer, _selector, _name, _object) \
  [[NSNotificationCenter defaultCenter] addObserver:_observer \
                                           selector:_selector \
                                               name:_name     \
                                             object:_object]
#define UNREGISTER_ALL_NOTIFY(_observer) \
  [[NSNotificationCenter defaultCenter] removeObserver:_observer]
#define GETNIB() \
  [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil]

#define IS_OS_8_OR_LATER \
  ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)


#endif
