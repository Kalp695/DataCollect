//
//  RectSearchViewController.h
//  DataCollect
//
//  Created by liucc on 3/31/14.
//  Copyright (c) 2014 liucc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OverlaySelectionView.h"

typedef struct {
    CLLocationDegrees minLatitude;
    CLLocationDegrees maxLatitude;
    CLLocationDegrees minLongtitude;
    CLLocationDegrees maxLongtitude;
}LocationBounds;

@interface RectSearchViewController : UIViewController<MKMapViewDelegate,OverlaySelectionViewDelegate>{
    LocationBounds searchBounds;
    UIBarButtonItem * areaBtn;
}

@end
