//
//  SM_LocationKit.h
//  FacebookFixture
//
//  Created by Karthikeya Udupa on 10/18/13.
//  Copyright (c) 2013 Karthikeya Udupa K M. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#define TimeOutFailure 0
#define AuthorizationFailure 1

@interface SM_LocationKit : NSObject <CLLocationManagerDelegate>

@property(strong, nonatomic) CLLocationManager *locator;
@property(strong, nonatomic) CLLocation *currentLocation;
@property(strong, nonatomic) CLLocation *lastLocation;
@property(strong, nonatomic) NSDate *lastUpdated;
@property BOOL locatorIsAuthorized;
@property BOOL isCurrentlyBusy;

typedef void (^LESuccessBlock)(CLLocation *loc);
typedef void (^LEPlacemarkBlock)(CLPlacemark *place);
typedef void (^LEFailureBlock)(NSInteger failCode);
typedef void (^LEFoursquareSuccessBlock)(NSArray *venues);
@property(strong, nonatomic) LESuccessBlock successBlock;
@property(strong, nonatomic) LEFailureBlock failureBlock;

+ (SM_LocationKit *)sharedInstance;
- (void)stopCompleteUpdating;
+ (void)getBallParkLocationOnSuccess:(LESuccessBlock)successBlock
                           onFailure:(LEFailureBlock)failureBlock;
+ (void)getPlacemarkLocationOnSuccess:(LEPlacemarkBlock)completionBlock
                            onFailure:(LEFailureBlock)failureBlock;

@end
