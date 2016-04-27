//
//  Landmark.h
//  WhereTo
//
//  Created by Allen Spicer on 4/27/16.
//  Copyright © 2016 Allen Spicer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Landmark : NSObject <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

@property(nonatomic, readonly, copy, nullable) NSString * title;

@property(nonatomic, readonly, copy, nullable) NSString * subtitle;

-(nullable instancetype)initWithCoord:(CLLocationCoordinate2D)coord title:(nullable NSString*) titleString subtitlle:(nullable NSString* ) subtitleString;






@end
