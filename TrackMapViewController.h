//
//  TrackMapViewController.h
//  DataCollect
//
//  Created by liucc on 2/18/14.
//  Copyright (c) 2014 liucc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MapKit/MapKit.h>
#import "Track.h"


@interface TrackMapViewController : UIViewController
@property(nonatomic,strong)IBOutlet MKMapView *mapView;
@property(nonatomic,strong)Track *track;
@property(nonatomic,strong)NSString *timeStamp;
@property(nonatomic,strong)NSString *dirPath;

-(IBAction)close:(id)sender;
@end
