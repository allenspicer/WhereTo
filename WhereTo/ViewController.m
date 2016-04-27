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

@interface ViewController () <CLLocationManagerDelegate>

@property (strong, nonatomic) MKMapView *mapView;
//must create property to correct the fact that the object dissapears immediatly after view loads
@property(strong, nonatomic) CLLocationManager *manager;


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

    
    //creat class/object called landmark - inherit from nsobject
    //build out landmark object
    // apply landmark class
    
    Landmark * capitalBuilding = [[Landmark alloc] initWithCoord:CLLocationCoordinate2DMake(35.7804, -78.6391) title:@"Capital Building" subtitlle:@"The place where the capital is"];
    
    //place mark on map
    [self.mapView addAnnotation:capitalBuilding];
    
    self.manager.delegate = self;
    [self.manager startUpdatingLocation];
    
    //display user location
    self.mapView.showsUserLocation = YES;
    
    //must first ask for location. two types - when in use and always on
    //put in CLLocation manager  instance ( a request for permission) above
    

    
    //create CL Location from capial building instance of landmark class
    CLLocation * capitalLocation = [[CLLocation alloc]initWithLatitude:capitalBuilding.coordinate.latitude longitude:capitalBuilding.coordinate.longitude];
    
    CLLocation * currentLocation = self.mapView.userLocation.location;
    
    if (currentLocation && capitalLocation) {
    
    [self zoomMapToRegionEncapsulatingLocation:capitalLocation andLocation:currentLocation];
    }
        
        
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)centerMapOnLocation:(CLLocationCoordinate2D)location{
    
    
    
}

-(void)zoomMapToRegionEncapsulatingLocation:(CLLocation*)firstLoc andLocation:(CLLocation*)secondLoc{
    
    //define point halfway between one latitude and another
    float lat = (firstLoc.coordinate.latitude + secondLoc.coordinate.latitude) /2;
    
    //dfine same for longitude
    float longitude = (firstLoc.coordinate.longitude + secondLoc.coordinate.latitude) /2;
    
    //create distance between the two
    CLLocationDistance distance = [firstLoc distanceFromLocation:secondLoc]/111.0f;
    
    CLLocation *centerLocation = [[CLLocation alloc]initWithLatitude:lat longitude:longitude];
    
    MKCoordinateSpan span = MKCoordinateSpanMake(distance, distance);
    
    MKCoordinateRegion region = MKCoordinateRegionMake(centerLocation.coordinate, span);
    
    [self.mapView setRegion:region];
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
    
    CLLocation * currentLocation = self.mapView.userLocation.location;
    
    if (currentLocation && capitalLocation) {
        
        [self zoomMapToRegionEncapsulatingLocation:capitalLocation andLocation:currentLocation];
    }
    
    
    [manager stopUpdatingLocation];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
