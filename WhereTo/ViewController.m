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
    
    
    self.manager.delegate = self;
    [self.manager startUpdatingLocation];
    
    UIBarButtonItem * locationButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonPressed:)];
    self.navigationItem.leftBarButtonItem = locationButton;
    
    
    //display user location
    self.mapView.showsUserLocation = YES;
    
    //must first ask for location. two types - when in use and always on
    //put in CLLocation manager instance (a request for permission) above
    
    [self.manager requestAlwaysAuthorization];


    
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
    
    
__block CLLocation * firstCityLocation = [[CLLocation alloc]init];

__block CLLocation * secondCityLocation = [[CLLocation alloc]init];
    

    
    //take city locations
    NSLog(@"%@", cityArray[0]);
    NSLog(@"%@", cityArray[1]);
    //create variaibles to hold locations


    //place them into forward geocoder
    CLGeocoder * geocoder = [[CLGeocoder alloc]init];
    NSString *firstCityString = [[NSString alloc]init];
    firstCityString = cityArray[0];
    
    [geocoder geocodeAddressString:firstCityString completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error){
    CLPlacemark *placemark = [placemarks objectAtIndex:0];
            
            float lat = placemark.location.coordinate.latitude;
            float lon = placemark.location.coordinate.longitude;
            
            NSLog(@"%f",lat);
            NSLog(@"%f",lon);
            
            
            Landmark * firstCity = [[Landmark alloc] initWithCoord:CLLocationCoordinate2DMake(lat, lon) title:@"First City" subtitlle:@""];
            firstCityLocation = [[CLLocation alloc]initWithLatitude:lat longitude:lon];
            
        
            
            
            [[self mapView]addAnnotation:(firstCity)];
            

        }else{
            NSLog(@"Error");
        }
        
    }];
    

    
        //place them into forward geocoder
        CLGeocoder * geocoder2 = [[CLGeocoder alloc]init];
        NSString *secondCityString = [[NSString alloc]init];
        secondCityString = cityArray[1];
    
        [geocoder2 geocodeAddressString:secondCityString completionHandler:^(NSArray *placemarks, NSError *error) {
            if (!error){
                CLPlacemark *placemark = [placemarks objectAtIndex:0];
                
                float lat = placemark.location.coordinate.latitude;
                float lon = placemark.location.coordinate.longitude;
                
                NSLog(@"%f",lat);
                NSLog(@"%f",lon);
                
                
                Landmark * secondCity = [[Landmark alloc] initWithCoord:CLLocationCoordinate2DMake(lat, lon) title:@"Second City" subtitlle:@""];
                secondCityLocation = [[CLLocation alloc]initWithLatitude:lat longitude:lon];

                
                [[self mapView]addAnnotation:(secondCity)];
                
            }else{
                NSLog(@"Error");
            }
            
            
            
            
            CLLocationDistance distance = [firstCityLocation distanceFromLocation:secondCityLocation];
            // distance is a double representing the distance in meters
            NSLog(@"%f", distance);
            
            NSString *titleString = [NSString stringWithFormat:@"%0.0f Meters",distance];
            
            self.title = titleString;
        
}];

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
    
    if (CLLocationCoordinate2DIsValid(centerLocation.coordinate)){
        
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(centerLocation.coordinate, distance,distance);
        
        [self.mapView setRegion:region animated:YES];
        
    }
}




#pragma mark





#pragma mark Navigation Controller







- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
