//
//  kmViewController.h
//  DataCollect
//
//  Created by liucc on 4/10/14.
//  Copyright (c) 2014 liucc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "kParser.h"

@interface kmViewController : UIViewController {
    IBOutlet MKMapView *map;
    kParser *kmlParser;
}

@property(nonatomic,strong)NSMutableArray *kmlData;

@end