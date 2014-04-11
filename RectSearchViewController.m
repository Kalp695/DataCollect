//
//  RectSearchViewController.m
//  DataCollect
//
//  Created by liucc on 3/31/14.
//  Copyright (c) 2014 liucc. All rights reserved.
//

#import "RectSearchViewController.h"

@interface RectSearchViewController (){
    MKMapView *mapView;
}

@end

@implementation RectSearchViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initMapView];
    [self initSearchBtn];
	// Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -Private Mehod
-(void)initMapView{
    mapView=[[MKMapView alloc]initWithFrame:self.view.frame];
    [self.view addSubview:mapView];
}

-(void)initSearchBtn{
    UIBarButtonItem *rightBarButtonItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(selectArea)];
    self.navigationItem.rightBarButtonItem=rightBarButtonItem;

}

-(void)selectArea{
    OverlaySelectionView* overlay = [[OverlaySelectionView alloc] initWithFrame: self.view.frame];
    overlay.delegate = self;
    [self.view addSubview: overlay];
}

#pragma mark -OverlaySelectionViewDelegate

-(void)areaSelected:(CGRect)screenArea{
    CGPoint point = screenArea.origin;
    // we must account for upper nav bar height!
    point.y -= 44;
    CLLocationCoordinate2D upperLeft = [mapView convertPoint: point toCoordinateFromView: mapView];
    point.x += screenArea.size.width;
    CLLocationCoordinate2D upperRight = [mapView convertPoint: point toCoordinateFromView: mapView];
    point.x -= screenArea.size.width;
    point.y += screenArea.size.height;
    CLLocationCoordinate2D lowerLeft = [mapView convertPoint: point toCoordinateFromView: mapView];
    point.x += screenArea.size.width;
    CLLocationCoordinate2D lowerRight = [mapView convertPoint: point toCoordinateFromView: mapView];
    
    searchBounds.minLatitude = MIN(lowerLeft.latitude, lowerRight.latitude);
    searchBounds.minLongtitude = MIN(upperLeft.longitude, lowerLeft.longitude);
    searchBounds.maxLatitude = MAX(upperLeft.latitude, upperRight.latitude);
    searchBounds.maxLatitude = MAX(upperRight.longitude, lowerRight.longitude);
    
    // TODO: comment out to keep search rectangle on screen
    [[self.view.subviews lastObject] removeFromSuperview];
}

@end
