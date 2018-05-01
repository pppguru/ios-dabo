//
//  MDSGeocodingViewController.h
//  Map Kit Demo
//
//  Created by Ryan Johnson on 3/18/12.
//  Copyright (c) 2012 mobile data solutions.

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

#import "SM_LocationKit.h"

@protocol MDSGeoCodingDelegate<NSObject>
- (void)selectedLocation:(NSString *)locationInformation
         withCoordinates:(CLLocationCoordinate2D)coordinate;
- (void)dismiss;
@end

@interface MDSGeocodingViewController
    : UIViewController<UISearchDisplayDelegate, MKMapViewDelegate> {
  IBOutlet UISearchBar *searchBar;
  IBOutlet UILabel *distanceLbl;

  CLPlacemark *currentPlacemark;
  CLLocationCoordinate2D selectedCoord;

  MKCircle *radiusCircle;
  BOOL isSaveRequired;
  IBOutlet UISlider *radiusSlider;
}
@property(nonatomic, assign) id<MDSGeoCodingDelegate> delegate;
+ (MDSGeocodingViewController *)viewController;
@end
