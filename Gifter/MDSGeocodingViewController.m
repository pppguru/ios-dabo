//
//  MDSGeocodingViewController.m
//  Map Kit Demo
//
//  Created by Ryan Johnson on 3/18/12.
//  Copyright (c) 2012 mobile data solutions.
//

#import "MDSGeocodingViewController.h"
#define DEGREES_RADIANS(angle) ((angle) / 180.0 * M_PI)

@interface MDSGeocodingViewController () {
  IBOutlet MKMapView *_mapView;
  NSMutableArray *_geocodingResults;
  CLGeocoder *_geocoder;
  NSTimer *_searchTimer;
  double longitude;
  double latitude;
  BOOL isUserLocation;
}

@end

@implementation MDSGeocodingViewController

+ (MDSGeocodingViewController *)viewController {
  return
      [[self alloc] initWithNibName:@"MDSGeocodingViewController" bundle:nil];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.title = NSLocalizedString(@"Location", @"");

  _geocodingResults = [[NSMutableArray alloc] init];
  _geocoder = [[CLGeocoder alloc] init];

  [self.navigationItem
      setRightBarButtonItem:[[UIBarButtonItem alloc]
                                initWithTitle:@"Done"
                                        style:UIBarButtonItemStyleDone
                                       target:self
                                       action:@selector(doneAction)]];

  [self.navigationItem
      setLeftBarButtonItem:[[UIBarButtonItem alloc]
                               initWithTitle:@"Cancel"
                                       style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(CancelAction)]];

  searchBar = [[UISearchBar alloc] init];
  [searchBar setDelegate:(id<UISearchBarDelegate>)self];
  self.navigationItem.titleView = searchBar;
}

- (IBAction)doneAction {
  if (currentPlacemark) {
    NSString *address = [NSString
        stringWithFormat:@"%@",
                         [currentPlacemark.addressDictionary
                             valueForKey:@"FormattedAddressLines"]
                             ? [(NSArray *)[currentPlacemark.addressDictionary
                                   valueForKey:@"FormattedAddressLines"]
                                   componentsJoinedByString:@", "]
                             : [NSString
                                   stringWithFormat:@"%0.3f, %0.3f",
                                                    selectedCoord.latitude,
                                                    selectedCoord.longitude]];

    [self.delegate selectedLocation:address
                    withCoordinates:currentPlacemark.location.coordinate];
  }
}

- (IBAction)CancelAction {
  [self.delegate dismiss];
}

- (void)loadUserLocation {
  [SM_LocationKit sharedInstance];
  [SM_LocationKit getPlacemarkLocationOnSuccess:^(CLPlacemark *place) {

    isUserLocation = YES;
    _mapView.showsUserLocation = YES;
    [_mapView removeAnnotations:_mapView.annotations];
    selectedCoord = place.location.coordinate;
    [self zoomToCoordinate:place.location.coordinate];
    [self redrawRadiusCircle];
    currentPlacemark = place;

  } onFailure:^(NSInteger failCode) {
    isUserLocation = NO;
    [[[UIAlertView alloc]
            initWithTitle:@""
                  message:@"Unable to fetch your location. Please check the "
                  @"permission and try again."
                 delegate:nil
        cancelButtonTitle:@"OK"
        otherButtonTitles:nil] show];
  }];
}

- (void)redrawRadiusCircle {
  dispatch_async(dispatch_get_main_queue(), ^{
    [_mapView removeOverlay:radiusCircle];
    radiusCircle =
        [MKCircle circleWithCenterCoordinate:selectedCoord
                                      radius:radiusSlider.value * 1000];
    [_mapView addOverlay:radiusCircle];
    [distanceLbl
        setText:[NSString stringWithFormat:@"%0.0f mi", radiusSlider.value]];
  });
}

- (IBAction)monitorRadiusChange:(id)sender {
  [self redrawRadiusCircle];
  [self zoomToCoordinate:selectedCoord];
}

#pragma mark - Geocoding Methods
NSString *const kSearchTextKey = @"Search Text";

- (void)geocodeFromTimer:(NSTimer *)timer {
  NSString *searchString = [timer.userInfo objectForKey:kSearchTextKey];
  if (_geocoder.isGeocoding) [_geocoder cancelGeocode];

  [_geocoder geocodeAddressString:searchString
                completionHandler:^(NSArray *placemark, NSError *error) {
                  if (!error) {
                    [self processForwardGeocodingResults:placemark];
                  } else {
                    [_geocodingResults removeAllObjects];
                  }
                }];
}

- (void)processForwardGeocodingResults:(NSArray *)placemarks {
  if (_geocodingResults)
    [_geocodingResults removeAllObjects];
  else
    _geocodingResults = [[NSMutableArray alloc] init];
  [_geocodingResults addObjectsFromArray:placemarks];

  [_mapView removeAnnotations:_mapView.annotations];

  currentPlacemark = [_geocodingResults objectAtIndex:0];

  selectedCoord = currentPlacemark.location.coordinate;

  [self addPinAnnotationForPlacemark:currentPlacemark];
  [_mapView setShowsUserLocation:NO];
  isUserLocation = NO;

  [self.searchDisplayController setActive:NO animated:YES];
  [_geocodingResults removeAllObjects];

  [self zoomMapToPlacemark:currentPlacemark];
}

- (void)didLongPress:(UILongPressGestureRecognizer *)gr {
  if (gr.state == UIGestureRecognizerStateBegan) {
    // convert the touch point to a CLLocationCoordinate & geocode
    CGPoint touchPoint = [gr locationInView:_mapView];
    CLLocationCoordinate2D coord =
        [_mapView convertPoint:touchPoint toCoordinateFromView:_mapView];
    selectedCoord = coord;

    //[MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
      MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
      
      hud.labelText = @"Feels good to Dabo";

    [self reverseGeocodeCoordinate:coord];
  }
}

- (void)reverseGeocodeCoordinate:(CLLocationCoordinate2D)coord {
  if ([_geocoder isGeocoding]) [_geocoder cancelGeocode];

  CLLocation *location = [[CLLocation alloc] initWithLatitude:coord.latitude
                                                    longitude:coord.longitude];

  [_geocoder reverseGeocodeLocation:location
                  completionHandler:^(NSArray *placemarks, NSError *error) {
                    if (!error) {
                      [self processReverseGeocodingResults:placemarks];
                    } else {
                      [MBProgressHUD
                          hideAllHUDsForView:self.navigationController.view
                                    animated:YES];
                    }
                  }];
}

- (void)processReverseGeocodingResults:(NSArray *)placemarks {
  [MBProgressHUD hideAllHUDsForView:self.navigationController.view
                           animated:YES];
  if ([placemarks count] == 0) return;

  CLPlacemark *placemark = [placemarks objectAtIndex:0];
  currentPlacemark = placemark;

  NSString *address = [NSString
      stringWithFormat:@"%@",
                       [currentPlacemark.addressDictionary
                           valueForKey:@"FormattedAddressLines"]
                           ? [(NSArray *)[currentPlacemark.addressDictionary
                                 valueForKey:@"FormattedAddressLines"]
                                 componentsJoinedByString:@", "]
                           : [NSString
                                 stringWithFormat:@"%0.3f, %0.3f",
                                                  selectedCoord.latitude,
                                                  selectedCoord.longitude]];

  searchBar.text = address;

  [self addPinAnnotationForCoord:placemark.location.coordinate];
  [_mapView setShowsUserLocation:NO];
  isUserLocation = NO;
}

- (void)addPinAnnotationForCoord:(CLLocationCoordinate2D)coordinate {
  [_mapView removeAnnotations:_mapView.annotations];
  MKPointAnnotation *placemarkAnnotation = [[MKPointAnnotation alloc] init];
  placemarkAnnotation.coordinate = coordinate;
  placemarkAnnotation.title = @"";
  [_mapView addAnnotation:placemarkAnnotation];
  selectedCoord = coordinate;
  [self redrawRadiusCircle];

  [self zoomToCoordinate:coordinate];
}

- (void)addPinAnnotationForPlacemark:(CLPlacemark *)placemark {
  MKPointAnnotation *placemarkAnnotation = [[MKPointAnnotation alloc] init];
  placemarkAnnotation.coordinate = placemark.location.coordinate;
  placemarkAnnotation.title = @"";
  [_mapView addAnnotation:placemarkAnnotation];
  _mapView.showsUserLocation = NO;
  selectedCoord = placemark.location.coordinate;
  [self redrawRadiusCircle];
}

- (void)zoomMapToPlacemark:(CLPlacemark *)selectedPlacemark {
  CLLocationCoordinate2D coordinate = selectedPlacemark.location.coordinate;
  [self zoomToCoordinate:coordinate];
}

- (void)zoomToCoordinate:(CLLocationCoordinate2D)coordinate {
  MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(
      coordinate, (radiusSlider.value * 2000), radiusSlider.value * 2000);

  [_mapView setRegion:region animated:YES];
}

#pragma mark - UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller
    shouldReloadTableForSearchString:(NSString *)searchString {
  // Use a timer to only start geocoding when the user stops typing
  if ([_searchTimer isValid]) [_searchTimer invalidate];

  const NSTimeInterval kSearchDelay = .25;
  NSDictionary *userInfo =
      [NSDictionary dictionaryWithObject:searchString forKey:kSearchTextKey];
  _searchTimer =
      [NSTimer scheduledTimerWithTimeInterval:kSearchDelay
                                       target:self
                                     selector:@selector(geocodeFromTimer:)
                                     userInfo:userInfo
                                      repeats:NO];

  return NO;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)_searchBar {
  [_searchBar resignFirstResponder];
  //[MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    hud.labelText = @"Feels good to Dabo";
  if ([[_searchBar text] length]) {
    if (_geocoder.isGeocoding) [_geocoder cancelGeocode];

    [_geocoder geocodeAddressString:_searchBar.text
                  completionHandler:^(NSArray *placemark, NSError *error) {
                    if (!error) {
                      isSaveRequired = YES;
                      [self processForwardGeocodingResults:placemark];
                    } else {
                      [[[UIAlertView alloc]
                              initWithTitle:@""
                                    message:@"Unable to find any location "
                                    @"with the particular name."
                                   delegate:nil
                          cancelButtonTitle:@"Okay"
                          otherButtonTitles:nil] show];

                      [_geocodingResults removeAllObjects];
                    }

                    dispatch_async(dispatch_get_main_queue(), ^{
                      [MBProgressHUD
                          hideAllHUDsForView:self.navigationController.view
                                    animated:YES];
                    });
                  }];
  }
}
// called when bookmark button pressed
- (void)searchBarCancelButtonClicked:(UISearchBar *)_searchBar {
  [_searchBar resignFirstResponder];
}

#pragma mark - MKMapView Delegate Methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id<MKAnnotation>)annotation {
  static NSString *const kPinIdentifier = @"Pin";
  MKPinAnnotationView *pin = (MKPinAnnotationView *)
      [mapView dequeueReusableAnnotationViewWithIdentifier:kPinIdentifier];
  if (!pin)
    pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                          reuseIdentifier:kPinIdentifier];

  pin.annotation = annotation;

  return pin;
}

@end