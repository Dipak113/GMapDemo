//
//  ViewController.m
//  GMapDemo
//
//  Created by Dipak Dhondge on 28/05/18.
//  Copyright © 2018 Dipak Dhondge. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>
@interface ViewController ()<CLLocationManagerDelegate,GMSAutocompleteViewControllerDelegate,GMSAutocompleteResultsViewControllerDelegate,GMSMapViewDelegate,UISearchBarDelegate,UISearchControllerDelegate,UINavigationBarDelegate>{
    GMSPlacesClient *_placesClient;
    CLLocationManager * locationManager;
    GMSAutocompleteResultsViewController * _resultsViewController;
    UISearchController * _searchController;
    GMSGeocoder *geocoder_;
    NSArray *tableData;
    //GMSMapView *mapView_;
    GMSCameraPosition *camera;
    GMSPlace *selectedPlace;
    double lattitudeaddress;
    double longitudeaddress;
  //  SucessenSingletonClass* sharedSingleton;
    
    
    NSMutableArray * arrUserCommunityLongitude;
    NSMutableArray * arrUserCommunityLatitude;
    NSMutableArray * arrUserNames;
    NSMutableArray * arrUserLastName;
    NSMutableArray * arrUserMailId;
    NSMutableArray * arrUserProfilePic;
    NSMutableArray * arrUserAddress;
    NSMutableArray * arrUserCity;
    NSMutableArray * arrUserCountry;
    NSMutableArray * arrUserState;
    NSMutableArray * arrUserStatus;
    
    NSDictionary * dictResult;
    NSDictionary * dictResultUser;
    NSMutableArray * arrResultCommunityUser;
    NSString * strCurrentUserLatitude;
    NSString * strCurrentUserLongitude;
    //NearByMe
    NSDictionary * dictNearByMe;
    NSMutableArray * arrNearByMe;
    
    NSString * refreshActivebtn;
}

@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) IBOutlet GMSMapView *subViewMap;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *lat;
@property (strong, nonatomic) NSString *lng;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *country;
@property (weak, nonatomic) IBOutlet UIView *viewAddressContainer;
@property (strong, nonatomic) IBOutlet UIView *subVVIew;
@property (weak, nonatomic) IBOutlet UISwitch * switchOnOff;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _addressLabel.hidden = YES;
    //SharedInstance Code
    
    _placesClient = [GMSPlacesClient sharedClient];
    locationManager.delegate = self;
    
    CLLocationCoordinate2D center;
    center.latitude = [self.lat doubleValue];
    center.longitude = [self.lng doubleValue];
    self.addressLabel.text = self.address;
    
    _resultsViewController = [[GMSAutocompleteResultsViewController alloc] init];
    _resultsViewController.delegate = self;
    _searchController = [[UISearchController alloc]
                         initWithSearchResultsController:_resultsViewController];
    _searchController.searchResultsUpdater = _resultsViewController;

    
    [_searchController.searchBar setSearchFieldBackgroundImage:[UIImage imageNamed:@"txtSearchBar"] forState:UIControlStateNormal];//setSearchFieldBackgroundImage(UIImage(named: "SearchFieldBackground"), for: UIControlState.normal)
    // Color of typed text in the search bar.
    NSDictionary *searchBarTextAttributes = @{
                                              NSForegroundColorAttributeName: [UIColor blackColor],
                                              NSFontAttributeName : [UIFont systemFontOfSize:[UIFont systemFontSize]]
                                              };
    [UITextField appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]]
    .defaultTextAttributes = searchBarTextAttributes;
    
    
    // Color of the placeholder text in the search bar prior to text entry.
    NSDictionary *placeholderAttributes = @{
                                            NSForegroundColorAttributeName:[UIColor darkGrayColor],
                                            NSFontAttributeName : [UIFont systemFontOfSize:[UIFont systemFontSize]]
                                            };
    
    // Color of the default search text.
    // NOTE: In a production scenario, "Search" would be a localized string.
    NSAttributedString *attributedPlaceholder =
    [[NSAttributedString alloc] initWithString:@"Search"
                                    attributes:placeholderAttributes];
    [UITextField appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]]
    .attributedPlaceholder = attributedPlaceholder;
    
    // [[UIBarButtonItem appearanceWhenContainedIn: [ _searchController.searchBar class], nil] setTintColor:[UIColor redColor]];
    
    //Set The Cancel Button Text
    //[[UIBarButtonItem appearanceWhenContainedIn: [ _searchController.searchBar class], nil] setTitle:@"Your Text Here"];
    
    // [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:[UISearchBar class] setTintColor:[UIColor redColor];
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTintColor:[UIColor blackColor]];
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTintColor:[UIColor blackColor]];
    
    _searchController.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _searchController.searchBar.delegate = self;
    _searchController.delegate = self;
    _searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
   // [_searchController.searchBar sizeToFit];
   // self.navigationItem.titleView = _searchController.searchBar;
    self.definesPresentationContext = YES;
    // Work around a UISearchController bug that doesn't reposition the table view correctly when
    // rotating to landscape.
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.extendedLayoutIncludesOpaqueBars = YES;
    _searchController.hidesNavigationBarDuringPresentation = NO;
    // [self.subViewMap addSubview:subView];
//     [_subVVIew addSubview:_searchController.searchBar];
    
    
    arrNearByMe = [[NSMutableArray alloc]init];
    arrUserMailId = [[NSMutableArray alloc]init];
    arrUserProfilePic = [[NSMutableArray alloc]init];
    arrUserCity = [[NSMutableArray alloc]init];
    arrUserCountry = [[NSMutableArray alloc]init];
    arrUserAddress = [[NSMutableArray alloc]init];
    arrUserState = [[NSMutableArray alloc]init];
    
    refreshActivebtn = @"NO";
    
    //CHeck Online or Offline Status
    [_switchOnOff setSelected:YES];
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    //Drawer Innovation
    [self GetCFTCummunityData];
}


-(void)GetCFTCummunityData{
    arrResultCommunityUser = [[NSMutableArray alloc]init];
    arrUserNames = [[NSMutableArray alloc]init];
    arrUserCommunityLongitude = [[NSMutableArray alloc]init];
    arrUserCommunityLatitude = [[NSMutableArray alloc]init];
    arrUserLastName = [[NSMutableArray alloc]init];
    arrUserMailId = [[NSMutableArray alloc]init];
    arrUserProfilePic = [[NSMutableArray alloc]init];
    arrUserCity = [[NSMutableArray alloc]init];
    arrUserCountry = [[NSMutableArray alloc]init];
    arrUserAddress = [[NSMutableArray alloc]init];
    arrUserState = [[NSMutableArray alloc]init];
    arrUserStatus = [[NSMutableArray alloc]init];
    
     arrUserCommunityLatitude = [[NSMutableArray alloc]initWithObjects:@"18.509890",@"18.562622",@"18.055609",@"18.536208",@"18.528424", nil];
     arrUserCommunityLongitude = [[NSMutableArray alloc]initWithObjects:@"73.807182",@"73.808723",@"74.484800",@"73.893975",@"73.873865", nil];
     arrUserAddress = [[NSMutableArray alloc]initWithObjects:@"1",@"2",@"3",@"4",@"5", nil];
    
    [self loadView];
}


-(CLLocationCoordinate2D) getLocationFromAddressString: (NSString*) addressStr {
    double latitude = 0, longitude = 0;
    NSString *esc_addr =  [addressStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *req = [NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?sensor=false&address=%@", esc_addr];
    NSString *result = [NSString stringWithContentsOfURL:[NSURL URLWithString:req] encoding:NSUTF8StringEncoding error:NULL];
    if (result) {
        NSScanner *scanner = [NSScanner scannerWithString:result];
        if ([scanner scanUpToString:@"\"lat\" :" intoString:nil] && [scanner scanString:@"\"lat\" :" intoString:nil]) {
            [scanner scanDouble:&latitude];
            if ([scanner scanUpToString:@"\"lng\" :" intoString:nil] && [scanner scanString:@"\"lng\" :" intoString:nil]) {
                [scanner scanDouble:&longitude];
            }
        }
    }
    CLLocationCoordinate2D center;
    center.latitude=latitude;
    center.longitude = longitude;
    lattitudeaddress = latitude;
    longitudeaddress = longitude;
    NSLog(@"View Controller get Location Logitute : %f",center.latitude);
    NSLog(@"View Controller get Location Latitute : %f",center.longitude);
    return center;
    
}

- (void)loadView {
    // Create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 6.
    [super loadView];
    
    //  NSArray * Lat=[NSArray arrayWithObjects:@"18.509890",@"18.562622",@"18.055609",@"18.536208",@"18.528424", nil];
    // NSArray * Long=[NSArray arrayWithObjects:@"73.807182",@"73.808723",@"74.484800",@"73.893975",@"73.873865", nil];
    // NSArray * arrlbls = [NSArray arrayWithObjects:@"1",@"2",@"3",@"4",@"5", nil];
    NSLog(@"%f",[strCurrentUserLatitude doubleValue]);
    if ([arrUserCommunityLatitude count]>0) {
        camera = [GMSCameraPosition cameraWithLatitude:[[arrUserCommunityLatitude objectAtIndex:0]doubleValue]//[strCurrentUserLatitude doubleValue]
                                             longitude:[[arrUserCommunityLongitude objectAtIndex:0]doubleValue]//[strCurrentUserLongitude doubleValue]
                                                  zoom:8];
        
        //    camera = [GMSCameraPosition cameraWithLatitude:34.078159//[strCurrentUserLatitude doubleValue]
        //                                         longitude:-118.260559//[strCurrentUserLongitude doubleValue]
        //                                              zoom:8];
        // _subViewMap = [GMSMapView mapWithFrame:CGRectMake(self.subViewMap.frame.origin.x,54,self.view.frame.size.width,self.view.frame.size.height) camera:camera];
        
        _subViewMap.delegate = self;
        _subViewMap.myLocationEnabled = YES;
        // self.view = mapView_;
        for (int i=0; i<[arrUserCommunityLatitude count]; i++) {
            GMSMarker *marker = [[GMSMarker alloc] init];
            marker.position = CLLocationCoordinate2DMake([[arrUserCommunityLatitude objectAtIndex:i]doubleValue], [[arrUserCommunityLongitude objectAtIndex:i]doubleValue]);
            marker.title = [NSString stringWithFormat:@"%@",arrUserAddress];
            //marker.snippet = [arrUserCity objectAtIndex:i];
            UIButton * btnIconView = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
            btnIconView.backgroundColor = [UIColor redColor];
            // marker.iconView = btnIconView;
            marker.appearAnimation = kGMSMarkerAnimationPop ;
            //marker.infoWindowAnchor = CGPointMake(0.1, 0.1);
           // marker.icon = [UIImage imageNamed:@"redmarker4848"];
            marker.map = _subViewMap;
        }
        _subViewMap.camera = camera;
        
    }
   // [self.view addSubview:_searchController.searchBar];
    [_subVVIew addSubview:_searchController.searchBar];
}



- (void)saveImage: (UIImage*)image indexValue:(NSUInteger)indexValues{
    if (image != nil){
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* path = [documentsDirectory stringByAppendingPathComponent:
                          [NSString stringWithFormat:@"%ld",indexValues]];
        NSLog(@"%@",path);
        NSData* data = UIImagePNGRepresentation(image);
        [data writeToFile:path atomically:YES];
    }
}

- (UIImage*)loadImage:(NSUInteger)indexVal {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"%ld",indexVal]];
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    return image;
}

// Present the autocomplete view controller when the button is pressed.
- (IBAction)onLaunchClicked:(id)sender {
    GMSAutocompleteViewController *acController = [[GMSAutocompleteViewController alloc] init];
    acController.delegate = self;
    [self presentViewController:acController animated:YES completion:nil];
}

#pragma mark - GMSAutocompleteResultsViewControllerDelegate
// Handle the user's selection.
- (void)resultsController:(GMSAutocompleteResultsViewController *)resultsController
 didAutocompleteWithPlace:(GMSPlace *)place {
    // Do something with the selected place.
    NSLog(@"Place name %@", place.name);
    NSLog(@"Place address %@", place.formattedAddress);
    NSLog(@"Place attributions %@", place.attributions.string);
    [self dismissViewControllerAnimated:YES completion:nil];
    GMSMarker *marker = [[GMSMarker alloc] init];
    //[self getLocationFromAddressString:@"texas,austin,usa"];
    marker.position = CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude);
    marker.title = place.attributions.string;
    marker.snippet = place.attributions.string;
    marker.map = _subViewMap;
    
    camera = [GMSCameraPosition cameraWithLatitude:place.coordinate.latitude
                                         longitude:place.coordinate.longitude
                                              zoom:6];
    //self.googleMapsView.camera = camera
    _subViewMap.camera = camera;
    //   mapView_ = [GMSMapView mapWithFrame:self.view.frame camera:camera];
    
    for (int i=0; i<[arrUserCommunityLatitude count]; i++) {
    
    GMSMutablePath *path = [GMSMutablePath path];
    [path addCoordinate:CLLocationCoordinate2DMake([[arrUserCommunityLatitude objectAtIndex:i]doubleValue],[[arrUserCommunityLongitude objectAtIndex:i]doubleValue])];
    [path addCoordinate:CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude)];
    
    GMSPolyline *rectangle = [GMSPolyline polylineWithPath:path];
    rectangle.strokeWidth = 2.f;
    rectangle.map = _subViewMap;
    }
}
// User canceled the operation.
- (void)wasCancelled:(GMSAutocompleteViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)resultsController:(GMSAutocompleteResultsViewController *)resultsController
didFailAutocompleteWithError:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    // TODO: handle the error.
    NSLog(@"Error: %@", [error description]);
}

// Turn the network activity indicator on and off again.
- (void)didRequestAutocompletePredictionsForResultsController:
(GMSAutocompleteResultsViewController *)resultsController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didUpdateAutocompletePredictionsForResultsController:
(GMSAutocompleteResultsViewController *)resultsController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)didPresentSearchController:(UISearchController *)searchController{
    [searchController.searchBar becomeFirstResponder];
}

#pragma mark - GMSMapViewDelegate
// func locateWithLongitude(_ lon: Double, andLatitude lat: Double, andTitle title: String)
-(void)locateWithLongitude:(double)Long lat:(double)lat andTitle:(NSString*)Title{
    
}

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position{
    
    
    
}

- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker{
   
    return nil;
}


-(void)TapOnAction:(UIButton*)sender{
    NSLog(@"Button Tap");
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker{
    //marker.title,marker.snippet
    NSLog(@"%@%@",marker.title,marker.snippet);
    _subViewMap.selectedMarker = nil;
}

- (void)mapView:(GMSMapView *)mapView didLongPressInfoWindowOfMarker:(GMSMarker *)marker {
    NSString *message =
    [NSString stringWithFormat:@"Info window for marker %@ long pressed.", marker.title];
    [self.view removeFromSuperview];
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate{
    
}

- (void) mapView: (GMSMapView *)mapView didChangeCameraPosition: (GMSCameraPosition *)position {
    
    if (selectedPlace != nil) {
        selectedPlace = nil;
        return;
    }
    double latitude = mapView.camera.target.latitude;
    double longitude = mapView.camera.target.longitude;
    CLLocationCoordinate2D addressCoordinates = CLLocationCoordinate2DMake(latitude,longitude);
    GMSGeocoder* coder = [[GMSGeocoder alloc] init];
    [coder reverseGeocodeCoordinate:addressCoordinates completionHandler:^(GMSReverseGeocodeResponse *results, NSError *error) {
        if (error) {
            // NSLog(@"Error %@", error.description);
            self.country = @"";
            self.city = @"";
        } else {
            GMSAddress* address = [results firstResult];
            self.city = address.locality ? address.locality : @"";
            self.country = address.country ? address.country : @"";
            NSArray *arr = [address valueForKey:@"lines"];
            NSString *str1 = [NSString stringWithFormat:@"%lu",(unsigned long)[arr count]];
            if ([str1 isEqualToString:@"0"]) {
                self.addressLabel.text = @"";
            }
            else if ([str1 isEqualToString:@"1"]) {
                NSString *str2 = [arr objectAtIndex:0];
                self.addressLabel.text = str2;
            }
            else if ([str1 isEqualToString:@"2"]) {
                NSString *str2 = [arr objectAtIndex:0];
                NSString *str3 = [arr objectAtIndex:1];
                if (str2.length > 1 ) {
                    self.addressLabel.text = [NSString stringWithFormat:@"%@,%@",str2,str3];
                }
                else {
                    self.addressLabel.text = [NSString stringWithFormat:@"%@",str3];
                }
            }
        }
    }];
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker{
    CGPoint point = [mapView.projection pointForCoordinate:marker.position];
    point.y = point.y - 100;
    GMSCameraUpdate *camera =
    [GMSCameraUpdate setTarget:[mapView.projection coordinateForPoint:point]];
    [mapView animateWithCameraUpdate:camera];
    
    mapView.selectedMarker = marker;
    return YES;
}

- (void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture {
    //this will clear all the markers...
    //[mapView clear];
}

- (IBAction)locateCurrentLocation:(id)sender {
    NSLog(@"%f%f",_subViewMap.myLocation.coordinate.latitude,_subViewMap.myLocation.coordinate.longitude);
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:18.509890 longitude:73.807182 zoom:8];
    [_subViewMap setCamera:camera];
    NSString * strLatitude = [NSString stringWithFormat:@"%f", _subViewMap.myLocation.coordinate.latitude];
    NSString * strLongitude = [NSString stringWithFormat:@"%f", _subViewMap.myLocation.coordinate.longitude ];
    
    //Delete Document Directory
    NSString *folderPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSError *error = nil;
    for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:&error]) {
        [[NSFileManager defaultManager] removeItemAtPath:[folderPath stringByAppendingPathComponent:file] error:&error];
    }
    
}




//  "userId": "70",
//"platform": "3",
//“userLatitude”:34.063145”,
//“userLongitude”:”-118.436755”

-(void)GetNearByUsersForme:(NSString*)strUserLatitude strUserLongitude:(NSString*)strUserLongitude{
    arrResultCommunityUser = [[NSMutableArray alloc]init];
    arrUserNames = [[NSMutableArray alloc]init];
    arrUserCommunityLongitude = [[NSMutableArray alloc]init];
    arrUserCommunityLatitude = [[NSMutableArray alloc]init];
    arrUserLastName = [[NSMutableArray alloc]init];
    arrUserMailId = [[NSMutableArray alloc]init];
    arrUserProfilePic = [[NSMutableArray alloc]init];
    arrUserCity = [[NSMutableArray alloc]init];
    arrUserCountry = [[NSMutableArray alloc]init];
    arrUserAddress = [[NSMutableArray alloc]init];
    arrUserState = [[NSMutableArray alloc]init];
    arrUserStatus = [[NSMutableArray alloc]init];
            
            [self loadView];
   
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.- (void)viewController:(nonnull GMSAutocompleteViewController *)viewController didAutocompleteWithPlace:(nonnull GMSPlace *)place {<#code#>
}

- (CLLocationCoordinate2D) geoCodeUsingAddress:(NSString *)address{
    CLLocationCoordinate2D center;
    NSString *esc_addr =  [address stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *req = [NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?sensor=false&address=%@", esc_addr];
    
    NSData *responseData = [[NSData alloc] initWithContentsOfURL:
                            [NSURL URLWithString:req]];    NSError *error;
    NSMutableDictionary *responseDictionary = [NSJSONSerialization
                                               JSONObjectWithData:responseData
                                               options:0
                                               error:&error];
    if( error )
    {
        NSLog(@"%@", [error localizedDescription]);
        center.latitude = 0;
        center.longitude = 0;
        return center;
    }
    else {
        NSArray *results = (NSArray *) responseDictionary[@"results"];
        NSDictionary *firstItem = (NSDictionary *) [results objectAtIndex:0];
        NSDictionary *geometry = (NSDictionary *) [firstItem objectForKey:@"geometry"];
        NSDictionary *location = (NSDictionary *) [geometry objectForKey:@"location"];
        NSNumber *lat = (NSNumber *) [location objectForKey:@"lat"];
        NSNumber *lng = (NSNumber *) [location objectForKey:@"lng"];
        
        center.latitude = [lat doubleValue];
        center.longitude = [lng doubleValue];
        return center;
    }
}

//PolyLine Code
//GMSMutablePath *path = [GMSMutablePath path];
//[path addLatitude:_subViewMap.myLocation.coordinate.latitude longitude:_subViewMap.myLocation.coordinate.longitude];
//[path addLatitude:[[arrUserCommunityLatitude objectAtIndex:i]doubleValue] longitude:[[arrUserCommunityLongitude objectAtIndex:i]doubleValue]];
//GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
//polyline.strokeWidth = 5.0f;
//polyline.geodesic = YES;
//polyline.map = _subViewMap;

@end

