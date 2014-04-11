//
//  SearchByRectMapViewController.h
//  DataCollect
//
//  Created by liucc on 3/20/14.
//  Copyright (c) 2014 liucc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OverlaySelectionView.h"

typedef struct {
    CLLocationDegrees minLatitude;
    CLLocationDegrees maxLatitude;
    CLLocationDegrees minLongitude;
    CLLocationDegrees maxLongitude;
}LocationBounds;


@interface SearchByRectMapViewController : UIViewController<MKMapViewDelegate,OverlaySelectionViewDelegate>{
    LocationBounds searchBounds;
    MKMapView *mapView;
    
}

@end
