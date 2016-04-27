//
//  Landmark.m
//  WhereTo
//
//  Created by Allen Spicer on 4/27/16.
//  Copyright © 2016 Allen Spicer. All rights reserved.
//

#import "Landmark.h"

@implementation Landmark


-(nullable instancetype)initWithCoord:(CLLocationCoordinate2D)coord title:(nullable NSString*) titleString subtitlle:(nullable NSString* ) subtitleString
//were dealing with read only properties so we cant refer to them as self
{
    self = [super init];
    if (self) {
        _coordinate = coord;
        _title = titleString;
        _subtitle = subtitleString;
    }
    return self;
}

//
//-(instancetype)init{
//    CLLocationManager *manager = [[CLLocationManager alloc] init];
//    [manager requestAlwaysAuthorization];
//
//    return self;
//}
//







@end
