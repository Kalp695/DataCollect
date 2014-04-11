//
//  SearchByRectMapViewController.m
//  DataCollect
//
//  Created by liucc on 3/20/14.
//  Copyright (c) 2014 liucc. All rights reserved.
//

#import "SearchByRectMapViewController.h"
#import "SearchViewController.h"

@interface SearchByRectMapViewController ()

@end

@implementation SearchByRectMapViewController

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
    [self addRightBtn];
    
    
    
    mapView=[[MKMapView alloc]initWithFrame:self.view.frame];
    [self.view addSubview:mapView];
	// Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addRightBtn{
    UIBarButtonItem *rightBtn=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(selectArea)];
    self.navigationItem.rightBarButtonItem=rightBtn;
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
    searchBounds.minLongitude = MIN(upperLeft.longitude, lowerLeft.longitude);
    searchBounds.maxLatitude = MAX(upperLeft.latitude, upperRight.latitude);
    searchBounds.maxLongitude = MAX(upperRight.longitude, lowerRight.longitude);
    
    [[self.view.subviews lastObject] removeFromSuperview];
    NSLog(@"upla:%f,uplo:%f;lola:%f,lolo:%f",upperLeft.latitude,upperLeft.longitude,lowerRight.longitude,lowerRight.latitude);
    
    NSString *startPointLatitude=[NSString stringWithFormat:@"%f",upperLeft.latitude];
    NSString *startPointLongitude=[NSString stringWithFormat:@"%f",upperLeft.longitude];
    NSString *endPointLatitude=[NSString stringWithFormat:@"%f",lowerRight.latitude];
    NSString *endPointLongitude=[NSString stringWithFormat:@"%f",lowerRight.longitude];
    
    NSArray *areaArray=@[startPointLatitude,startPointLongitude,endPointLatitude,endPointLongitude];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"areaNotification" object:areaArray];
    //相当于nav的返回按钮
    [self.navigationController popViewControllerAnimated:YES];


    
    
}
-(void)selectArea{
    OverlaySelectionView *overlay=[[OverlaySelectionView alloc]initWithFrame:self.view.frame];
    overlay.delegate=self;
    [self.view addSubview:overlay];
}



@end
