//
//  TrackPoint.h
//  GPSLogger
//
//  Created by NextBusinessSystem on 12/01/26.
//  Copyright (c) 2012 NextBusinessSystem Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

@class Track;

@interface TrackPoint : NSManagedObject

@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSNumber * altitude;
@property (nonatomic, retain) Track *track;
@property(nonatomic,retain)NSString *script;
@property(nonatomic,retain)NSString *imagepath;
@property(nonatomic,retain)NSString *videopath;
@property(nonatomic,retain)NSString *audiopath;
@property(nonatomic,retain) NSString *keyIndex;
- (CLLocationCoordinate2D)coordinate;

@end
