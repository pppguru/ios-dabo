//
//  SM_LocationKit.m
//  FacebookFixture
//
//  Created by Karthikeya Udupa on 10/18/13.
//  Copyright (c) 2013 Karthikeya Udupa K M. All rights reserved.
//

#import "SM_LocationKit.h"
#define UNACCEPTABLE_ACCURACY_IN_METERS 2000
#define LOCATION_REQUEST_TIMEOUT 5
#define DISTANCE_FILTER 1000

@implementation SM_LocationKit
BOOL _timerIsValid;
static SM_LocationKit *currentEngineInstance = nil;

+ (SM_LocationKit *)sharedInstance {
  @synchronized(self) {
    return [[self alloc] init];
  }
  return currentEngineInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
  @synchronized(self) {
    if (currentEngineInstance == nil) {
      currentEngineInstance = [super allocWithZone:zone];
      currentEngineInstance.locator = [[CLLocationManager alloc] init];
      [currentEngineInstance.locator
          setDesiredAccuracy:kCLLocationAccuracyKilometer];
      [currentEngineInstance.locator setDistanceFilter:DISTANCE_FILTER];
      currentEngineInstance.locator.delegate = currentEngineInstance;

      if ([currentEngineInstance.locator
              respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [currentEngineInstance.locator requestWhenInUseAuthorization];
      }
    }
    return currentEngineInstance;
  }
  return nil;
}

+ (void)getBallParkLocationOnSuccess:(LESuccessBlock)successBlock
                           onFailure:(LEFailureBlock)failureBlock {
  if ([CLLocationManager locationServicesEnabled]) {
    SM_LocationKit *le = [self sharedInstance];
    le.successBlock = successBlock;
    le.failureBlock = failureBlock;
    [le scheduleTimeout];
    [le.locator startUpdatingLocation];
  } else {
    if (failureBlock) {
      failureBlock(AuthorizationFailure);
    }
  }
}

+ (void)getPlacemarkLocationOnSuccess:(LEPlacemarkBlock)completionBlock
                            onFailure:(LEFailureBlock)failureBlock {
  [self getBallParkLocationOnSuccess:^(CLLocation *loc) {
      CLGeocoder *geo = [[CLGeocoder alloc] init];
      [geo reverseGeocodeLocation:loc
                completionHandler:^(NSArray *placemarks, NSError *error) {
                    completionBlock([placemarks objectAtIndex:0]);
                }];
  } onFailure:failureBlock];
}

- (BOOL)isInvalidLocation {
  return self.currentLocation.horizontalAccuracy < 0 ? YES : NO;
}

- (BOOL)isSufficientlyAccurate {
  return (self.currentLocation.horizontalAccuracy <
          UNACCEPTABLE_ACCURACY_IN_METERS)
             ? YES
             : NO;
}

- (BOOL)accuracyHasImproved {
  if (!self.lastLocation)
    return YES;
  return self.currentLocation.horizontalAccuracy <
                 self.lastLocation.horizontalAccuracy
             ? YES
             : NO;
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
  [self stopUpdating];
  if (self.failureBlock) {
    self.failureBlock(AuthorizationFailure);
  }
  self.successBlock = nil;
  self.failureBlock = nil;
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
  self.lastLocation = self.currentLocation;
  self.currentLocation = [locations lastObject];
  if ([self isInvalidLocation]) {
    self.currentLocation = self.lastLocation;
  } else {
    if ([self isSufficientlyAccurate]) {
      [self stopUpdating];
      if (self.successBlock) {
        self.successBlock(self.currentLocation);
        self.successBlock = nil;
        self.failureBlock = nil;
      }
    }
  }
}

- (void)locationManager:(CLLocationManager *)manager
    didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
  switch (status) {
  case kCLAuthorizationStatusAuthorized:
    self.locatorIsAuthorized = YES;
    break;
  case kCLAuthorizationStatusDenied:
    self.locatorIsAuthorized = NO;
    break;
  case kCLAuthorizationStatusNotDetermined:
    self.locatorIsAuthorized = NO;
    break;
  case kCLAuthorizationStatusRestricted:
    self.locatorIsAuthorized = NO;
    break;
  case kCLAuthorizationStatusAuthorizedWhenInUse:
    self.locatorIsAuthorized = YES;
  default:
    break;
  }
}

- (void)scheduleTimeout {
  [NSTimer scheduledTimerWithTimeInterval:LOCATION_REQUEST_TIMEOUT
                                   target:self
                                 selector:@selector(timesUp)
                                 userInfo:nil
                                  repeats:NO];
  _timerIsValid = YES;
}

- (void)timesUp {
  if (_timerIsValid) {
    if (self.failureBlock)
      self.failureBlock(TimeOutFailure);
    [self stopUpdating];
    self.failureBlock = nil;
    self.successBlock = nil;
  }
}

- (void)stopUpdating {
  [self.locator stopUpdatingLocation];
  [self.locator stopUpdatingHeading];
  [self.locator stopMonitoringSignificantLocationChanges];

  _timerIsValid = NO;
}

- (void)stopCompleteUpdating {
  [self.locator stopUpdatingLocation];
  [self.locator stopUpdatingHeading];
  [self.locator stopMonitoringSignificantLocationChanges];
  for (CLCircularRegion *c in [self.locator monitoredRegions]) {
    [self.locator stopMonitoringForRegion:c];
  }
  _timerIsValid = NO;
}

@end
