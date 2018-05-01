//
//  GTAPIClient.m
//  Gifter
//
//  Created by Karthik on 29/03/2015.
//
//

#import "GTAPIClient.h"
#import "AppDelegate.h"
#import "KTUtility.h"

@class AppDelegate;

NSString *const WSK_DATA_SECTION_KEY = @"data";
NSString *const WSK_STATUS_KEY = @"success";
NSString *const WSK_ERROR_CODE_KEY = @"error_code";
NSString *const WSK_ERROR_MESSAGE_KEY = @"error_message";
NSString *const WSK_SERVICE_ID_KEY = @"service_id";
NSString *const WSK_SERVICE_TYPE_ID_KEY = @"service_type_id";
NSString *const WSK_AUTH_TOKEN = @"auth_token";
NSString *const WSK_SEARCH_KEYWORD_KEY = @"search_string";
NSString *const WSK_NOTIFICATION_KEY = @"notifications";
NSString *const WSK_USER_FIRST_NAME_KEY = @"first_name";
NSString *const WSK_USER_LAST_NAME_KEY = @"last_name";
NSString *const WSK_USER_TELEPHONE_KEY = @"phone";
NSString *const WSK_USER_PROFILE_IMAGE_KEY = @"image";
NSString *const WSK_USER_EMAIL_KEY = @"username";
NSString *const WSK_APPOINTMENT_TIME_KEY = @"appointment_time";
NSString *const WSK_APPOINTMENT_TIME_ZONE_KEY = @"appointment_time_zone";
NSString *const WSK_FB_ID_KEY = @"facebook_id";
NSString *const WSK_FB_FNAME_KEY = @"first_name";
NSString *const WSK_FB_LNAME_KEY = @"last_name";
NSString *const WSK_FB_EMAIL_KEY = @"email";
NSString *const WSK_FB_IMAGE_KEY = @"profile_image";
NSString *const WSK_FB_FULL_NAME_KEY = @"name";
NSString *const WSK_PROMO_SUB_KEY = @"promo_subscribed";
NSString *const WSK_PROMO_UNSUB_KEY = @"promo_unsubscribed";
NSString *const WSK_APPOINTMENT_KEY = @"appointment_notifications";
NSString *const WSK_PUSH_KEY = @"push_token";
NSString *const WSK_OS_KEY = @"os";
NSString *const WSK_LATITUDE_KEY = @"latitude";
NSString *const WSK_LONGITUDE_KEY = @"longitude";
NSString *const WSK_NOTIFICATION_MSG_KEY = @"notification_msg";
NSString *const WSK_NOTIFICATION_ID_KEY = @"notification_id";

NSString *const WSK_PRODUCT_ID_KEY = @"product_id";
NSString *const WSK_STRIPE_TOKEN_KEY = @"token";

NSString *const WSK_LATITUDE_ALT_KEY = @"latitude";
NSString *const WSK_LONGITUDE_ALT_KEY = @"longitude";

NSString *const WSK_APPOINTMENT_ID_KEY = @"appointment_id";
NSString *const WSK_APPOINTMENT_STATUS_KEY = @"appointment_status";
NSString *const WSK_RATING_KEY = @"rating";
NSString *const WSK_REVIEW_TITLE_KEY = @"review_title";
NSString *const WSK_REVIEW_BODY_KEY = @"review_content";
NSString *const WSK_CATEGORY_KEY = @"category";
NSString *const WSK_CATEGORY_FILTERED_KEY = @"category_filtering";
NSString *const WSK_RADIUS_KEY = @"radius";
NSString *const WSK_USER_DEFAULT_LOCATION_KEY = @"user_location_enabled";
NSString *const WSK_ADDRESS_KEY = @"user_address";
NSString *const WSK_PAGE_KEY = @"page";

NSString *const WSK_USERNAME = @"username";
NSString *const WSK_PASSWORD = @"password";
NSString *const WSK_DEVICE_TOKEN = @"device_token";

//NSString *const WS_kBaseURL = @"http://giftedapp.advancode.co/api";
NSString *const WS_kBaseURL = @"http://api.daboapp.com/api";


NSString *const WS_kPolicyURL = @"http://giftedapp.lastminute.co/";

NSString *const WSM_kAuthenticate = @"/user/login";
NSString *const WSM_kAuthenticateThroughFacebook =
@"/user/authenticate-facebook";

NSString *const WSM_kUserProfile = @"/user/profile";
NSString *const WSM_kUserUpdate = @"/user/update-profile";
NSString *const WSM_kLogout = @"/user/logout";
NSString *const WSM_kForgotPassword = @"/user/reset";
NSString *const WSM_kRegister = @"/user/register";
NSString *const WSM_kUpdateNotificationToken = @"/user/token";

NSString *const WSM_kAddFriend = @"/user/add-friend";
NSString *const WSM_kListFriend = @"/user/get-friends";
NSString *const WSM_kGetRecommended = @"/gift/get-recommended";
NSString *const WSM_kGetGifts       = @"/gift/get-all";
NSString *const WSM_kServicesGet = @"/service/get";
NSString *const WSM_kRemoveFriend = @"/user/delete-friend";
NSString *const WSM_kAddressCreate = @"/address/create";
NSString *const WSM_kAllAddress = @"/address/get-all";


NSString *const WSM_kNotifications = @"/notification";

NSString *const WSM_kAppointmentRequest = @"/appointment/request";
NSString *const WSM_kAppointmentRequestNextAvailable = @"/appointment/rna";
NSString *const WSM_kAppointmentRemovalRequest = @"/appointment/remove";
NSString *const WSM_kAppointment = @"/user/appointment";
NSString *const WSM_kUpdateAppointmentStatus = @"/appointment/update";

NSString *const WSM_kCateogryList = @"/category/list";
NSString *const WSM_kPushMessage = @"/user/message";
NSString *const WSM_kGetServicesProvided = @"/service/get-names";

NSString *const WSM_kNotificationProximityUpdate = @"/notification/proximity";

NSString *const WSM_ERROR = @"com.gifter.webmanager";

NSString *const WSM_kMakePayment = @"/user/make-purchase";

@implementation GTAPIClient

+ (instancetype)sharedInstance {
    static GTAPIClient *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GTAPIClient alloc]
                    initWithBaseURL:
                    [NSURL
                     URLWithString:@"https://giftedapp.lastminute.co/public/api/"]];
    });
    return instance;
}

- (void)authenticateWithFacebook:(id)facebookResult
                         success:(void (^)(void))success
                         failure:(void (^)(NSError *er))failure {
    AFHTTPRequestOperationManager *manager =
    [AFHTTPRequestOperationManager manager];
    
     AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString *imageURL = @"";
    if ([facebookResult valueForKey:@"picture"]) {
        if ([[facebookResult valueForKey:@"picture"] valueForKey:@"data"]) {
            imageURL = [[[facebookResult valueForKey:@"picture"] valueForKey:@"data"]
                        valueForKey:@"url"];
        }
    }
    
    NSString *_url = [NSString
                      stringWithFormat:@"http://graph.facebook.com/%@/picture?type=normal",
                      [KTUtility objectOrNilForKey:@"id"
                                    fromDictionary:facebookResult]];
    if (delegate.deviceTokenStr.length == 0) {
        delegate.deviceTokenStr = @"";
    }
    NSDictionary *parameters = @{
                                 WSK_APPOINTMENT_TIME_ZONE_KEY : [[NSTimeZone systemTimeZone] name],
                                 WSK_FB_ID_KEY :
                                     [KTUtility objectOrNilForKey:@"id" fromDictionary:facebookResult],
                                 WSK_FB_FNAME_KEY : [KTUtility objectOrNilForKey:@"first_name"
                                                                  fromDictionary:facebookResult],
                                 WSK_FB_LNAME_KEY : [KTUtility objectOrNilForKey:@"last_name"
                                                                  fromDictionary:facebookResult],
                                 WSK_FB_EMAIL_KEY :
                                     [KTUtility objectOrNilForKey:@"email" fromDictionary:facebookResult],
                                 WSK_FB_FULL_NAME_KEY :
                                     [KTUtility objectOrNilForKey:@"name" fromDictionary:facebookResult],
                                 WSK_FB_IMAGE_KEY : _url,
                                 WSK_DEVICE_TOKEN :delegate.deviceTokenStr
                                 };
    
    [manager POST:[WS_kBaseURL
                   stringByAppendingString:WSM_kAuthenticateThroughFacebook]
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              if ([[[responseObject valueForKeyPath:WSK_DATA_SECTION_KEY]
                    valueForKey:WSK_AUTH_TOKEN] length] &&
                  [[responseObject valueForKeyPath:WSK_STATUS_KEY] boolValue] ==
                  true) {
                  [self saveSessionKey:[[responseObject valueForKeyPath:@"data"]
                                        valueForKey:@"auth_token"]];
                  [self saveUserInformation:[responseObject
                                             valueForKeyPath:WSK_DATA_SECTION_KEY]];
                  
                  [[NSNotificationCenter defaultCenter]
                   postNotificationName:WSM_kAuthenticate
                   object:nil];
                  success();
              } else {
                  NSError *er = [[NSError alloc]
                                 initWithDomain:WSM_ERROR
                                 code:400
                                 userInfo:@{
                                            @"error" : NSLocalizedString(
                                                                         @"Please verify the entered username or password.",
                                                                         @"")
                                            }];
                  failure(er);
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              
              if (operation.response.statusCode == 401) {
                  NSError *er =
                  [[NSError alloc] initWithDomain:WSM_ERROR
                                             code:400
                                         userInfo:@{
                                                    @"error" : NSLocalizedString(
                                                                                 @"Unable to register your "
                                                                                 @"facebook account with Gifted.",
                                                                                 @"")
                                                    }];
                  failure(er);
                  
              } else {
                  NSError *er =
                  [[NSError alloc] initWithDomain:WSM_ERROR
                                             code:500
                                         userInfo:@{
                                                    @"error" : NSLocalizedString(
                                                                                 @"Unable to connect to Gifted. "
                                                                                 @"Please try again later.",
                                                                                 @"")
                                                    }];
                  failure(er);
              }
          }];
}

- (void)authenticateWithUsername:(NSString *)username
                     andPassword:(NSString *)password
                         success:(void (^)(void))success
                         failure:(void (^)(NSError *er))failure {
    AFHTTPRequestOperationManager *manager =
    [AFHTTPRequestOperationManager manager];
    
     AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (delegate.deviceTokenStr.length == 0) {
        delegate.deviceTokenStr = @"";
    }
    NSDictionary *parameters = @{
                                 WSK_APPOINTMENT_TIME_ZONE_KEY : [[NSTimeZone systemTimeZone] name],
                                 WSK_USERNAME : username,
                                 WSK_PASSWORD : password,
                                WSK_DEVICE_TOKEN :delegate.deviceTokenStr
                                 };
    
    [manager POST:[WS_kBaseURL stringByAppendingString:WSM_kAuthenticate]
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              if ([[responseObject valueForKeyPath:WSK_DATA_SECTION_KEY]
                   valueForKey:WSK_AUTH_TOKEN] &&
                  [[responseObject valueForKeyPath:WSK_STATUS_KEY] boolValue] ==
                  true) {
                  [self saveSessionKey:[[responseObject valueForKeyPath:@"data"]
                                        valueForKey:@"auth_token"]];
                  [self saveUserInformation:[responseObject
                                             valueForKeyPath:WSK_DATA_SECTION_KEY]];
                  
                  [[NSNotificationCenter defaultCenter]
                   postNotificationName:WSM_kAuthenticate
                   object:nil];
                  success();
              } else {
                  NSError *er = [[NSError alloc]
                                 initWithDomain:WSM_ERROR
                                 code:400
                                 userInfo:@{
                                            @"error" : NSLocalizedString(
                                                                         @"Please verify the entered username or password.",
                                                                         @"")
                                            }];
                  failure(er);
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              
              if (operation.response.statusCode == 402) {
                  NSError *er = [[NSError alloc]
                                 initWithDomain:WSM_ERROR
                                 code:400
                                 userInfo:@{
                                            @"error" : NSLocalizedString(
                                                                         @"Please verify the entered username or password.",
                                                                         @"")
                                            }];
                  failure(er);
                  
              } else {
                  NSError *er =
                  [[NSError alloc] initWithDomain:WSM_ERROR
                                             code:500
                                         userInfo:@{
                                                    @"error" : NSLocalizedString(
                                                                                 @"Unable to connect to Gifted. "
                                                                                 @"Please try again later.",
                                                                                 @"")
                                                    }];
                  failure(er);
              }
          }];
}


- (void)registerWithUsername:(NSString *)username
                 andPassword:(NSString *)password
                   withImage:(NSData *)imageData
                     success:(void (^)(void))success
                     failure:(void (^)(NSError *er))failure {
    AFHTTPRequestOperationManager *manager =
    [AFHTTPRequestOperationManager manager];
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (delegate.deviceTokenStr.length == 0) {
        delegate.deviceTokenStr = @"";
    }
    NSDictionary *parameters = @{
                                 WSK_USERNAME : username,
                                 WSK_PASSWORD : password,
                                 WSK_OS_KEY : @"iOS",
                                 WSK_DEVICE_TOKEN :delegate.deviceTokenStr
                                 };
    
    [manager POST:[WS_kBaseURL stringByAppendingString:WSM_kRegister]
       parameters:parameters
constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    
    if (imageData) {
        [formData appendPartWithFileData:imageData
                                    name:WSK_USER_PROFILE_IMAGE_KEY
                                fileName:@"photo.jpg"
                                mimeType:@"image/jpeg"];
    }
    
}
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              if ([[responseObject valueForKeyPath:WSK_DATA_SECTION_KEY]
                   valueForKey:WSK_AUTH_TOKEN] &&
                  [[responseObject valueForKeyPath:WSK_STATUS_KEY] boolValue] ==
                  true) {
                  [self saveSessionKey:[[responseObject
                                         valueForKeyPath:WSK_DATA_SECTION_KEY]
                                        valueForKey:WSK_AUTH_TOKEN]];
                  [self saveUserInformation:[responseObject
                                             valueForKeyPath:WSK_DATA_SECTION_KEY]];
                  success();
              } else {
                  NSError *er = [[NSError alloc]
                                 initWithDomain:WSM_ERROR
                                 code:400
                                 userInfo:@{
                                            @"error" : NSLocalizedString(
                                                                         @"The email address already exists.", @"")
                                            }];
                  failure(er);
              }
              
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              if (operation.response.statusCode == 401) {
                  NSError *er = [[NSError alloc]
                                 initWithDomain:WSM_ERROR
                                 code:400
                                 userInfo:@{
                                            @"error" : NSLocalizedString(
                                                                         @"The email address already exists.", @"")
                                            }];
                  failure(er);
                  
              } else {
                  NSError *er =
                  [[NSError alloc] initWithDomain:WSM_ERROR
                                             code:500
                                         userInfo:@{
                                                    @"error" : NSLocalizedString(
                                                                                 @"Unable to connect to Gifted. "
                                                                                 @"Please try again later.",
                                                                                 @"")
                                                    }];
                  failure(er);
              }
          }];
}


- (void)fetchAllGifts:(NSDictionary *)filters
              success:(void (^)(NSArray *items))success
              failure:(void (^)(NSError *er))failure {
    AFHTTPRequestOperationManager *manager =
    [AFHTTPRequestOperationManager manager];
    
    NSMutableDictionary *parameters =
    [[NSMutableDictionary alloc] initWithDictionary:@{
                                                      WSK_AUTH_TOKEN : [[GTAPIClient sharedInstance] getAuthToken]
                                                      }];
    
    if (filters) {
        [parameters addEntriesFromDictionary:filters];
    }
    
    [manager POST:[WS_kBaseURL stringByAppendingString:WSM_kGetGifts]
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              if ([[responseObject valueForKeyPath:WSK_STATUS_KEY] boolValue] ==
                  true) {
                  success([responseObject valueForKeyPath:WSK_DATA_SECTION_KEY]);
              } else {
                  NSError *er = [[NSError alloc]
                                 initWithDomain:WSM_ERROR
                                 code:400
                                 userInfo:@{
                                            @"error" : NSLocalizedString(
                                                                         @"Error", @"")
                                            }];
                  failure(er);
              }
              
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              
              NSError *er =
              [[NSError alloc] initWithDomain:WSM_ERROR
                                         code:500
                                     userInfo:@{
                                                @"error" : NSLocalizedString(
                                                                             @"Unable to connect to Gifted. "
                                                                             @"Please try again later.",
                                                                             @"")
                                                }];
              failure(er);
          }];
}



- (void)fetchRecommendations:(NSDictionary *)filters
                     success:(void (^)(NSArray *items))success
                     failure:(void (^)(NSError *er))failure {
    AFHTTPRequestOperationManager *manager =
    [AFHTTPRequestOperationManager manager];
    
    NSMutableDictionary *parameters =
    [[NSMutableDictionary alloc] initWithDictionary:@{
                                                      WSK_AUTH_TOKEN : [[GTAPIClient sharedInstance] getAuthToken]
                                                      }];
    
    if (filters) {
        [parameters addEntriesFromDictionary:filters];
    }
    
    [manager POST:[WS_kBaseURL stringByAppendingString:WSM_kGetRecommended]
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              if ([[responseObject valueForKeyPath:WSK_STATUS_KEY] boolValue] ==
                  true) {
                  success([responseObject valueForKeyPath:WSK_DATA_SECTION_KEY]);
              } else {
                  NSError *er = [[NSError alloc]
                                 initWithDomain:WSM_ERROR
                                 code:400
                                 userInfo:@{
                                            @"error" : NSLocalizedString(
                                                                         @"The email address already exists.", @"")
                                            }];
                  failure(er);
              }
              
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              
              NSError *er =
              [[NSError alloc] initWithDomain:WSM_ERROR
                                         code:500
                                     userInfo:@{
                                                @"error" : NSLocalizedString(
                                                                             @"Unable to connect to Gifted. "
                                                                             @"Please try again later.",
                                                                             @"")
                                                }];
              failure(er);
          }];
}


- (void)forgotWithUsername:(NSString *)username
                   success:(void (^)(void))success
                   failure:(void (^)(NSError *er))failure {
    AFHTTPRequestOperationManager *manager =
    [AFHTTPRequestOperationManager manager];
    
    NSDictionary *parameters = @{
                                 WSK_USERNAME : username,
                                 };
    
    [manager POST:[WS_kBaseURL stringByAppendingString:WSM_kForgotPassword]
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              if ([[responseObject valueForKeyPath:WSK_STATUS_KEY] boolValue] ==
                  true) {
                  success();
              } else {
                  NSError *er = [[NSError alloc]
                                 initWithDomain:WSM_ERROR
                                 code:400
                                 userInfo:@{
                                            @"error" : NSLocalizedString(
                                                                         @"Please enter a valid username.", @"")
                                            }];
                  failure(er);
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSError *er =
              [[NSError alloc] initWithDomain:WSM_ERROR
                                         code:500
                                     userInfo:@{
                                                @"error" : NSLocalizedString(
                                                                             @"Unable to connect to Gifted. "
                                                                             @"Please try again later.",
                                                                             @"")
                                                }];
              failure(er);
          }];
}

- (BOOL)isUserLoggedIn {
    if ([[NSUserDefaults standardUserDefaults] valueForKey:WSK_AUTH_TOKEN]) {
        return YES;
    }
    
    return NO;
}

- (void)saveUserInformation:(NSDictionary *)userInfo {
    [[NSUserDefaults standardUserDefaults]
     setValue:[KTUtility objectOrNilForKey:WSK_USER_FIRST_NAME_KEY
                            fromDictionary:userInfo]
     forKey:WSK_USER_FIRST_NAME_KEY];
    
    [[NSUserDefaults standardUserDefaults]
     setValue:[KTUtility objectOrNilForKey:WSK_PASSWORD
                            fromDictionary:userInfo]
     forKey:WSK_PASSWORD];
    [[NSUserDefaults standardUserDefaults]
     setValue:[KTUtility objectOrNilForKey:WSK_USER_LAST_NAME_KEY
                            fromDictionary:userInfo]
     forKey:WSK_USER_LAST_NAME_KEY];
    [[NSUserDefaults standardUserDefaults]
     setValue:[KTUtility objectOrNilForKey:WSK_USER_TELEPHONE_KEY
                            fromDictionary:userInfo]
     forKey:WSK_USER_TELEPHONE_KEY];
    [[NSUserDefaults standardUserDefaults]
     setValue:[KTUtility objectOrNilForKey:WSK_USER_PROFILE_IMAGE_KEY
                            fromDictionary:userInfo]
     forKey:WSK_USER_PROFILE_IMAGE_KEY];
    [[NSUserDefaults standardUserDefaults]
     setValue:[KTUtility objectOrNilForKey:WSK_USER_EMAIL_KEY
                            fromDictionary:userInfo]
     forKey:WSK_USER_EMAIL_KEY];
    [[NSUserDefaults standardUserDefaults]
     setValue:[KTUtility objectOrNilForKey:@"address" fromDictionary:userInfo]
     forKey:@"address"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)getAuthToken {
    return
    [[NSUserDefaults standardUserDefaults] valueForKey:WSK_AUTH_TOKEN]
    ? [[NSUserDefaults standardUserDefaults] valueForKey:WSK_AUTH_TOKEN]
    : @"";
}

- (void)logoutUser {
    AFHTTPRequestOperationManager *manager =
    [AFHTTPRequestOperationManager manager];
    
    NSDictionary *parameters = @{
                                 WSK_AUTH_TOKEN :
                                     [[NSUserDefaults standardUserDefaults] valueForKeyPath:WSK_AUTH_TOKEN]
                                 ? [[NSUserDefaults standardUserDefaults]
                                    valueForKeyPath:WSK_AUTH_TOKEN]
                                 : @""
                                 };
    
    [manager POST:[WS_kBaseURL stringByAppendingString:WSM_kLogout]
       parameters:parameters
          success:nil
          failure:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:WSM_kLogout
                                                        object:nil];
    
    [KTUtility removeAllUserDefaultValues];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)saveSessionKey:(NSString *)authToken {
    [[NSUserDefaults standardUserDefaults] setValue:authToken
                                             forKey:WSK_AUTH_TOKEN];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)addPerson:(NSDictionary *)personInfo
    withPhotoData:(NSData *)data
      withSuccess:(void (^)(void))success
          failure:(void (^)(NSError *er))failure {
    AFHTTPRequestOperationManager *manager =
    [AFHTTPRequestOperationManager manager];
    
    NSMutableDictionary *parameters =
    [[NSMutableDictionary alloc] initWithDictionary:@{
                                                      WSK_AUTH_TOKEN : [[GTAPIClient sharedInstance] getAuthToken]
                                                      }];
    [parameters addEntriesFromDictionary:personInfo];
    [manager POST:[WS_kBaseURL stringByAppendingString:WSM_kAddFriend]
       parameters:parameters
constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    
    if (data) {
        [formData appendPartWithFileData:data
                                    name:WSK_USER_PROFILE_IMAGE_KEY
                                fileName:@"photo.jpg"
                                mimeType:@"image/jpeg"];
    }
    
}
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              if ([[responseObject valueForKeyPath:WSK_STATUS_KEY] boolValue] ==
                  true) {
                  success();
              } else {
                  if (operation.response.statusCode == 401) {
                      [[NSNotificationCenter defaultCenter]
                       postNotificationName:@"SESSION_EXPIRED_EVENT"
                       object:nil];
                      
                  } else {
                      NSError *er =
                      [[NSError alloc] initWithDomain:WSM_ERROR
                                                 code:500
                                             userInfo:@{
                                                        @"error" : NSLocalizedString(
                                                                                     @"Unable to connect to Gifted. "
                                                                                     @"Please try again later.",
                                                                                     @"")
                                                        }];
                      failure(er);
                  }
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error){
          }];
}

- (void)savePerson:(NSDictionary *)personInfo
     withPhotoData:(NSData *)data
       withSuccess:(void (^)(void))success
           failure:(void (^)(NSError *er))failure {
    AFHTTPRequestOperationManager *manager =
    [AFHTTPRequestOperationManager manager];
    
    NSMutableDictionary *parameters =
    [[NSMutableDictionary alloc] initWithDictionary:@{
                                                      WSK_AUTH_TOKEN : [[GTAPIClient sharedInstance] getAuthToken]
                                                      }];
    [parameters addEntriesFromDictionary:personInfo];
    [manager POST:[WS_kBaseURL stringByAppendingString:WSM_kAddFriend]
       parameters:parameters
constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    
    if (data) {
        [formData appendPartWithFileData:data
                                    name:WSK_USER_PROFILE_IMAGE_KEY
                                fileName:@"photo.jpg"
                                mimeType:@"image/jpeg"];
    }
    
}
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              if ([[responseObject valueForKeyPath:WSK_STATUS_KEY] boolValue] ==
                  true) {
                  success();
              } else {
                  if (operation.response.statusCode == 401) {
                      [[NSNotificationCenter defaultCenter]
                       postNotificationName:@"SESSION_EXPIRED_EVENT"
                       object:nil];
                      
                  } else {
                      NSError *er =
                      [[NSError alloc] initWithDomain:WSM_ERROR
                                                 code:500
                                             userInfo:@{
                                                        @"error" : NSLocalizedString(
                                                                                     @"Unable to connect to Gifted. "
                                                                                     @"Please try again later.",
                                                                                     @"")
                                                        }];
                      failure(er);
                  }
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error){
          }];
}

- (void)saveProfile:(NSDictionary *)personInfo
      withPhotoData:(NSData *)data
        withSuccess:(void (^)(void))success
            failure:(void (^)(NSError *er))failure {
    AFHTTPRequestOperationManager *manager =
    [AFHTTPRequestOperationManager manager];
    
    NSMutableDictionary *parameters =
    [[NSMutableDictionary alloc] initWithDictionary:@{
                                                      WSK_AUTH_TOKEN : [[GTAPIClient sharedInstance] getAuthToken]
                                                      }];
    
    if (personInfo) {
        [parameters addEntriesFromDictionary:personInfo];
    }
    
    [manager POST:[WS_kBaseURL stringByAppendingString:WSM_kUserUpdate]
       parameters:parameters
constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    
    if (data) {
        [formData appendPartWithFileData:data
                                    name:WSK_USER_PROFILE_IMAGE_KEY
                                fileName:@"photo.jpg"
                                mimeType:@"image/jpeg"];
    }
    
}
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              if ([[responseObject valueForKeyPath:WSK_STATUS_KEY] boolValue] ==
                  true) {
                  [self saveUserInformation:[responseObject
                                             valueForKeyPath:WSK_DATA_SECTION_KEY]];
                  
                  success();
              } else {
                  if (operation.response.statusCode == 401) {
                      [[NSNotificationCenter defaultCenter]
                       postNotificationName:@"SESSION_EXPIRED_EVENT"
                       object:nil];
                      
                  } else {
                      NSError *er =
                      [[NSError alloc] initWithDomain:WSM_ERROR
                                                 code:500
                                             userInfo:@{
                                                        @"error" : NSLocalizedString(
                                                                                     @"Unable to connect to Gifted. "
                                                                                     @"Please try again later.",
                                                                                     @"")
                                                        }];
                      failure(er);
                  }
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"---> %@", error);
              failure(error);
          }];
}

- (void)getPeoplewithSuccess:(void (^)(id responseData))success
                     failure:(void (^)(NSError *er))failure {
    AFHTTPRequestOperationManager *manager =
    [AFHTTPRequestOperationManager manager];
    NSMutableDictionary *parameters =
    [[NSMutableDictionary alloc] initWithDictionary:@{
                                                      WSK_AUTH_TOKEN : [[GTAPIClient sharedInstance] getAuthToken]
                                                      }];
    
    [manager POST:[WS_kBaseURL stringByAppendingString:WSM_kListFriend]
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              if ([[responseObject valueForKeyPath:WSK_STATUS_KEY] boolValue] ==
                  true) {
                  success(responseObject);
              } else {
                  if (operation.response.statusCode == 401) {
                      [[NSNotificationCenter defaultCenter]
                       postNotificationName:@"SESSION_EXPIRED_EVENT"
                       object:nil];
                      
                  } else {
                      NSError *er =
                      [[NSError alloc] initWithDomain:WSM_ERROR
                                                 code:500
                                             userInfo:@{
                                                        @"error" : NSLocalizedString(
                                                                                     @"Unable to connect to Gifted. "
                                                                                     @"Please try again later.",
                                                                                     @"")
                                                        }];
                      failure(er);
                  }
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              
              NSError *er =
              [[NSError alloc] initWithDomain:WSM_ERROR
                                         code:500
                                     userInfo:@{
                                                @"error" : NSLocalizedString(
                                                                             @"Unable to connect to Gifted. "
                                                                             @"Please try again later.",
                                                                             @"")
                                                }];
              failure(er);
              
          }];
}

- (void)removeFriend:(id)filters
         withSuccess:(void (^)(id responseData))success
             failure:(void (^)(NSError *er))failure {
    AFHTTPRequestOperationManager *manager =
    [AFHTTPRequestOperationManager manager];
    
    NSMutableDictionary *parameters =
    [[NSMutableDictionary alloc] initWithDictionary:@{
                                                      WSK_AUTH_TOKEN : [[GTAPIClient sharedInstance] getAuthToken]
                                                      }];
    
    if (filters) {
        [parameters addEntriesFromDictionary:filters];
    }
    
    [manager POST:[WS_kBaseURL stringByAppendingString:WSM_kRemoveFriend]
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              if ([[responseObject valueForKeyPath:WSK_STATUS_KEY] boolValue] ==
                  true) {
                  success(responseObject);
              } else {
                  if (operation.response.statusCode == 401) {
                      [[NSNotificationCenter defaultCenter]
                       postNotificationName:@"SESSION_EXPIRED_EVENT"
                       object:nil];
                      
                  } else {
                      NSError *er =
                      [[NSError alloc] initWithDomain:WSM_ERROR
                                                 code:500
                                             userInfo:@{
                                                        @"error" : NSLocalizedString(
                                                                                     @"Unable to connect to Gifted. "
                                                                                     @"Please try again later.",
                                                                                     @"")
                                                        }];
                      failure(er);
                  }
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              
              NSError *er =
              [[NSError alloc] initWithDomain:WSM_ERROR
                                         code:500
                                     userInfo:@{
                                                @"error" : NSLocalizedString(
                                                                             @"Unable to connect to Gifted. "
                                                                             @"Please try again later.",
                                                                             @"")
                                                }];
              failure(er);
              
          }];
}

- (void)addAddress:(NSDictionary *)personInfo withSuccess:(void (^)(void))success
           failure:(void (^)(NSError *er))failure {
    AFHTTPRequestOperationManager *manager =
    [AFHTTPRequestOperationManager manager];
    
    NSMutableDictionary *parameters =
    [[NSMutableDictionary alloc] initWithDictionary:@{
                                                      WSK_AUTH_TOKEN : [[GTAPIClient sharedInstance] getAuthToken]
                                                      }];
    
    if (personInfo) {
        [parameters addEntriesFromDictionary:personInfo];
    }
    
    [manager POST:[WS_kBaseURL stringByAppendingString:WSM_kAddressCreate]
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              if ([[responseObject valueForKeyPath:WSK_STATUS_KEY] boolValue] ==
                  true) {
                  success();
              } else {
                  if (operation.response.statusCode == 401) {
                      [[NSNotificationCenter defaultCenter]
                       postNotificationName:@"SESSION_EXPIRED_EVENT"
                       object:nil];
                      
                  } else {
                      NSError *er =
                      [[NSError alloc] initWithDomain:WSM_ERROR
                                                 code:500
                                             userInfo:@{
                                                        @"error" : NSLocalizedString(
                                                                                     @"Unable to connect to Gifted. "
                                                                                     @"Please try again later.",
                                                                                     @"")
                                                        }];
                      failure(er);
                  }
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              failure(error);
          }];
}

- (void)getAddresses:(void (^)(id responseData))success
             failure:(void (^)(NSError *er))failure {
    AFHTTPRequestOperationManager *manager =
    [AFHTTPRequestOperationManager manager];
    
    NSMutableDictionary *parameters =
    [[NSMutableDictionary alloc] initWithDictionary:@{
                                                      WSK_AUTH_TOKEN : [[GTAPIClient sharedInstance] getAuthToken]
                                                      }];
    
    [manager POST:[WS_kBaseURL stringByAppendingString:WSM_kAllAddress]
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              if ([[responseObject valueForKeyPath:WSK_STATUS_KEY] boolValue] ==
                  true) {
                  success(responseObject);
              } else {
                  if (operation.response.statusCode == 401) {
                      [[NSNotificationCenter defaultCenter]
                       postNotificationName:@"SESSION_EXPIRED_EVENT"
                       object:nil];
                      
                  } else {
                      NSError *er =
                      [[NSError alloc] initWithDomain:WSM_ERROR
                                                 code:500
                                             userInfo:@{
                                                        @"error" : NSLocalizedString(
                                                                                     @"Unable to connect to Gifted. "
                                                                                     @"Please try again later.",
                                                                                     @"")
                                                        }];
                      failure(er);
                  }
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              
              NSError *er =
              [[NSError alloc] initWithDomain:WSM_ERROR
                                         code:500
                                     userInfo:@{
                                                @"error" : NSLocalizedString(
                                                                             @"Unable to connect to Gifted. "
                                                                             @"Please try again later.",
                                                                             @"")
                                                }];
              failure(er);
              
          }];
}

- (void)makePaymentWithParams:(NSDictionary *)params withSuccess:(void (^)(id responseData))success
             failure:(void (^)(NSError *er))failure {
    AFHTTPRequestOperationManager *manager =
    [AFHTTPRequestOperationManager manager];
    
    
    [manager POST:[WS_kBaseURL stringByAppendingString:WSM_kMakePayment]
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              if ([[responseObject valueForKeyPath:WSK_STATUS_KEY] boolValue] ==
                  true) {
                  success(responseObject);
              } else {
                  if (operation.response.statusCode == 401) {
                      [[NSNotificationCenter defaultCenter]
                       postNotificationName:@"SESSION_EXPIRED_EVENT"
                       object:nil];
                      
                  } else {
                      NSError *er =
                      [[NSError alloc] initWithDomain:WSM_ERROR
                                                 code:500
                                             userInfo:@{
                                                        @"error" : NSLocalizedString(
                                                                                     @"Unable to connect to Gifted."
                                                                                     @"Please try again later.",
                                                                                     @"")
                                                        }];
                      failure(er);
                  }
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              
              NSError *er =
              [[NSError alloc] initWithDomain:WSM_ERROR
                                         code:500
                                     userInfo:@{
                                                @"error" : NSLocalizedString(
                                                                             @"Unable to connect to Gifted. "
                                                                             @"Please try again later.",
                                                                             @"")
                                                }];
              failure(er);
              
          }];
}


@end
