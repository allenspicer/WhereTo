//
//  ViewController.m
//  WhereTo
//
//  Created by Allen Spicer on 4/27/16.
//  Copyright © 2016 Allen Spicer. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import "Landmark.h"
#import <UIKit/UIKit.h>


@interface ViewController () <CLLocationManagerDelegate, UIPopoverPresentationControllerDelegate>

@property (strong, nonatomic) MKMapView *mapView;
//must create property to correct the fact that the object dissapears immediatly after view loads
@property(strong, nonatomic) CLLocationManager *manager;

@property (strong, nonatomic) UINavigationController *presentViewController;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *plusButton;

@property(strong, nonatomic)UIViewController *insideViewController;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //create frame for map (a CGRect)
    CGRect theFrame = self.view.frame;
    
    // specify how far the origin is from the top left to accomodate a border
    theFrame.origin.x = 20;
    
    // specify starting point of frame to accomodate the navigation bar
    //starting point (top left of the frame) will be left 20 and right 94 pixels
    theFrame.origin.y = 94;
    
    //specify new size of the frame (because of move)
    //create border on both sides 20*2
    theFrame.size.width -= 40;
    
    //resize for nav bar plus border on top and bottom (20*2)
    theFrame.size.height -=114;
    
    //cl location manager instance moved out of viewDidLoad
    CLLocationManager *manager = [[CLLocationManager alloc]init];
    [manager requestAlwaysAuthorization];
    self.manager = manager;
    
    
    
    //display map initialized above
    self.mapView = [[MKMapView alloc]initWithFrame:theFrame];
    
    //frame is a struct - value type, is set and we create new ones all the time, we dont modify just one
    
    [self.view addSubview:self.mapView];
    
  
    
    Landmark * capitalBuilding = [[Landmark alloc] initWithCoord:CLLocationCoordinate2DMake(35.7804, -78.6391) title:@"Capital Building" subtitlle:@"The place where the capital is"];
    
    //place mark on map
    [self.mapView addAnnotation:capitalBuilding];
    

//    Landmark * providence = [[Landmark alloc] initWithCoord:CLLocationCoordinate2DMake(41.8239891, -71.412834299) title:@"Providence, RI" subtitlle:@"Harry and Llyod Start"];
//    
//    [self.mapView addAnnotation:providence];
//    
//    Landmark * assspen = [[Landmark alloc] initWithCoord:CLLocationCoordinate2DMake(39.1910983, -106.8175387) title:@"Providence, RI" subtitlle:@"Harry and Llyod Start"];
//    
//    [self.mapView addAnnotation:assspen];
//    
    
    self.manager.delegate = self;
    [self.manager startUpdatingLocation];
    
    UIBarButtonItem * locationButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonPressed:)];
    self.navigationItem.leftBarButtonItem = locationButton;
    
    
    //display user location
    self.mapView.showsUserLocation = YES;
    
    //must first ask for location. two types - when in use and always on
    //put in CLLocation manager instance (a request for permission) above
    
    [self.manager requestAlwaysAuthorization];
    
    //create CL Location from capial building instance of landmark class
    CLLocation * capitalLocation = [[CLLocation alloc]initWithLatitude:capitalBuilding.coordinate.latitude longitude:capitalBuilding.coordinate.longitude];
    
    CLLocation * currentLocation = self.mapView.userLocation.location;
    
    if (currentLocation && capitalLocation) {
    
    [self zoomMapToRegionEncapsulatingLocation:capitalLocation andLocation:currentLocation];
    }
        

    
    // Do any additional setup after loading the view, typically from a nib.
}


-(UIViewController *)controllerForInsidePopover{
    UIViewController * createMeNow = [[UIViewController alloc]init];
    
    createMeNow.view.backgroundColor = UIColor.whiteColor;
    
    UITextField *firstText = [[UITextField alloc]initWithFrame:CGRectMake(10, 40, 300, 30)];
    firstText.borderStyle = UITextBorderStyleLine;
    firstText.tag = 5;
    [createMeNow.view addSubview: firstText];
    
    UITextField *secondText = [[UITextField alloc]initWithFrame:CGRectMake(10, 80, 300, 30)];
    secondText.borderStyle = UITextBorderStyleLine;
    secondText.tag = 6;
    [createMeNow.view addSubview: secondText];
    
    UIButton * closeMeButton = [[UIButton alloc]initWithFrame:CGRectMake(10, 120, 200, 35)];
    
    [closeMeButton setTitle:@"Close Me" forState:UIControlStateNormal];
    [closeMeButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    
    [closeMeButton addTarget:self action:@selector(closePopoverView) forControlEvents:UIControlEventTouchUpInside];
    
    [createMeNow.view addSubview:closeMeButton];
    
    return createMeNow;
}

-(void)closePopoverView{
    
    UITextField * firstText = [self.insideViewController.view viewWithTag:5];
    UITextField * secondText = [self.insideViewController.view viewWithTag:6];
    
    
    [self lookUpCities:@[firstText.text, secondText.text]];
    [self.insideViewController dismissViewControllerAnimated:YES completion:nil];

}

-(void)lookUpCities:(NSArray*)cityArray{
    NSAssert2(@"Both strings", @"are present", cityArray[0], cityArray[1]);
    
    CLGeocoder * geocoder = [[CLGeocoder alloc]init];
    
    __block CLLocationCoordinate2D firstPlace;
    __block CLLocationCoordinate2D secondPlace;
    
    __block ViewController * weakSelf = self;
    
    [geocoder geocodeAddressString:cityArray[0]
                 completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks,
                                     NSError * _Nullable error) {
                     CLPlacemark * placemark = [placemarks lastObject];
                     firstPlace = placemark.location.coordinate;
                        Landmark *theFirst = [[Landmark alloc]initWithCoord:firstPlace title:cityArray[0] subtitlle:@"The first location"];
                     [weakSelf.mapView addAnnotation:theFirst];
                     [geocoder cancelGeocode];
                     
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
    [geocoder geocodeAddressString:cityArray[1]
                 completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks,
                                     NSError * _Nullable error) {
                    CLPlacemark * placemark = [placemarks lastObject];
                    secondPlace = placemark.location.coordinate;
                    Landmark *theSecond = [[Landmark alloc]initWithCoord:secondPlace title:cityArray[1] subtitlle:@"The second location"];
                     [weakSelf.mapView addAnnotation:theSecond];
                     [geocoder cancelGeocode];
                     
                     }];
      });

}


-(IBAction)addButtonPressed: (UIBarButtonItem*)sender
{
    
    self.insideViewController = [self controllerForInsidePopover];
    self.insideViewController.modalPresentationStyle = UIModalPresentationPopover;

    UIPopoverPresentationController * popPresController = [self.insideViewController popoverPresentationController];
    
    popPresController.delegate = self;
    popPresController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popPresController.barButtonItem = sender;
    
    [self presentViewController:self.insideViewController animated:YES completion:nil];
    
}

-(UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller{
    
    return UIModalPresentationNone;
}





- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController{
    return YES;
}


-(void)centerMapOnLocation:(CLLocationCoordinate2D)location{
    
}

-(void)zoomMapToRegionEncapsulatingLocation:(CLLocation*)firstLoc andLocation:(CLLocation*)secondLoc{
    
    float lat =(firstLoc.coordinate.latitude + secondLoc.coordinate.latitude) /2;
    
    float longitude = (firstLoc.coordinate.longitude + secondLoc.coordinate.longitude) /2;
    
    
    CLLocationDistance distance = [firstLoc distanceFromLocation:secondLoc];
    
    CLLocation *centerLocation = [[CLLocation alloc]initWithLatitude:lat longitude:longitude];
    
    //    MKCoordinateSpan span = MKCoordinateSpanMake(2000, 2000);
    
    if (CLLocationCoordinate2DIsValid(centerLocation.coordinate)){
        
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(centerLocation.coordinate, distance,distance);
        
        [self.mapView setRegion:region animated:YES];
        
    }
}




#pragma mark


-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    CLLocation* firstLocation = [locations firstObject];
    CLLocation* lastLocation = [locations lastObject];
    
    if ([firstLocation isEqual: lastLocation]){
        NSLog(@"Same Place");
    }else{
        NSLog(@"Who knows!");
    }
    
    Landmark * capitalBuilding = [[Landmark alloc] initWithCoord:CLLocationCoordinate2DMake(35.7804, -78.6391) title:@"Capital Building" subtitlle:@"The place where the capital is"];
    
    //must first ask for location. two types - when in use and always on
    //put in CLLocation manager  instance ( a request for permission) above
    
    //create CL Location from capial building instance of landmark class
    CLLocation * capitalLocation = [[CLLocation alloc]initWithLatitude:capitalBuilding.coordinate.latitude longitude:capitalBuilding.coordinate.longitude];
    
    CLLocation * currentLocation = lastLocation;
    
    if (currentLocation && capitalLocation) {
        
        [self zoomMapToRegionEncapsulatingLocation:capitalLocation andLocation:currentLocation];
    }

    [manager stopUpdatingLocation];
}


#pragma mark Navigation Controller







- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
