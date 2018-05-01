//
//  GTAPIClient.h
//  Gifter
//
//  Created by Karthik on 29/03/2015.
//
//

#import "AFHTTPRequestOperationManager.h"

@interface GTAPIClient : AFHTTPRequestOperationManager
+ (instancetype)sharedInstance;
- (void)authenticateWithFacebook:(id)facebookResult
                         success:(void (^)(void))success
                         failure:(void (^)(NSError *er))failure;
- (void)authenticateWithUsername:(NSString *)username
                     andPassword:(NSString *)password
                         success:(void (^)(void))success
                         failure:(void (^)(NSError *er))failure;
- (void)registerWithUsername:(NSString *)username
                 andPassword:(NSString *)password
                   withImage:(NSData *)imageData
                     success:(void (^)(void))success
                     failure:(void (^)(NSError *er))failure;
- (void)forgotWithUsername:(NSString *)username
                   success:(void (^)(void))success
                   failure:(void (^)(NSError *er))failure;
- (NSString *)getAuthToken;
- (void)addPerson:(NSDictionary *)personInfo
    withPhotoData:(NSData *)data
      withSuccess:(void (^)(void))success
          failure:(void (^)(NSError *er))failure;
- (void)getPeoplewithSuccess:(void (^)(id responseData))success
                     failure:(void (^)(NSError *er))failure;

- (void)fetchAllGifts:(NSDictionary *)filters
              success:(void (^)(NSArray *items))success
              failure:(void (^)(NSError *er))failure;

- (void)fetchRecommendations:(NSDictionary *)filters
                     success:(void (^)(NSArray *items))success
                     failure:(void (^)(NSError *er))failure;
- (void)removeFriend:(id)filters
         withSuccess:(void (^)(id responseData))success
             failure:(void (^)(NSError *er))failure;
- (void)saveProfile:(NSDictionary *)personInfo
      withPhotoData:(NSData *)data
        withSuccess:(void (^)(void))success
            failure:(void (^)(NSError *er))failure;
- (void)savePerson:(NSDictionary *)personInfo
     withPhotoData:(NSData *)data
       withSuccess:(void (^)(void))success
           failure:(void (^)(NSError *er))failure;
- (void)addAddress:(NSDictionary *)personInfo
       withSuccess:(void (^)(void))success
           failure:(void (^)(NSError *er))failure;
- (void)getAddresses:(void (^)(id responseData))success
             failure:(void (^)(NSError *er))failure;
- (void)makePaymentWithParams:(NSDictionary *)params withSuccess:(void (^)(id responseData))success
                      failure:(void (^)(NSError *er))failure;

- (BOOL)isUserLoggedIn;
- (void)logoutUser;
@end
