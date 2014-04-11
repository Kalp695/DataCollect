//
//  kmViewController.m
//  DataCollect
//
//  Created by liucc on 4/10/14.
//  Copyright (c) 2014 liucc. All rights reserved.
//

#import "kmViewController.h"

@implementation kmViewController

- (void)viewDidLoad


{
    
    
    [super viewDidLoad];
    [self showKMLFromData:self.kmlData];
    
    // Locate the path to the route.kml file in the application's bundle
    // and parse it with the KMLParser.
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"log_20140410153034" ofType:@"kml"];
//    
//    NSLog(@"%@",path);
//    NSURL *url = [NSURL fileURLWithPath:path];
//    
//    kmlParser = [[kParser alloc] initWithURL:url];
//    [kmlParser parseKML];
//    
//    
//    // Add all of the MKOverlay objects parsed from the KML file to the map.
//    NSArray *overlays = [kmlParser overlays];
//    [map addOverlays:overlays];
//    
//    // Add all of the MKAnnotation objects parsed from the KML file to the map.
//    NSArray *annotations = [kmlParser points];
//    [map addAnnotations:annotations];
//    
//    // Walk the list of overlays and annotations and create a MKMapRect that
//    // bounds all of them and store it into flyTo.
//    MKMapRect flyTo = MKMapRectNull;
//    for (id <MKOverlay> overlay in overlays) {
//        if (MKMapRectIsNull(flyTo)) {
//            flyTo = [overlay boundingMapRect];
//        } else {
//            flyTo = MKMapRectUnion(flyTo, [overlay boundingMapRect]);
//        }
//    }
//    
//    for (id <MKAnnotation> annotation in annotations) {
//        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
//        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
//        if (MKMapRectIsNull(flyTo)) {
//            flyTo = pointRect;
//        } else {
//            flyTo = MKMapRectUnion(flyTo, pointRect);
//        }
//    }
//    
//    // Position the map so that all overlays and annotations are visible on screen.
//    map.visibleMapRect = flyTo;
//       [self addanotherKml];
}


-(void)showKMLFromData:(NSMutableArray *)dataArray{
    for (NSString *path in dataArray) {
//        NSString *path = [[NSBundle mainBundle] pathForResource:@"track" ofType:@"kml"];
        
        NSLog(@"%@",path);
        NSURL *url = [NSURL fileURLWithPath:path];
        
        kmlParser = [[kParser alloc] initWithURL:url];
        [kmlParser parseKML];
        
        
        // Add all of the MKOverlay objects parsed from the KML file to the map.
        NSArray *overlays = [kmlParser overlays];
        [map addOverlays:overlays];
        
        // Add all of the MKAnnotation objects parsed from the KML file to the map.
        NSArray *annotations = [kmlParser points];
        [map addAnnotations:annotations];
        
        // Walk the list of overlays and annotations and create a MKMapRect that
        // bounds all of them and store it into flyTo.
        MKMapRect flyTo = MKMapRectNull;
        for (id <MKOverlay> overlay in overlays) {
            if (MKMapRectIsNull(flyTo)) {
                flyTo = [overlay boundingMapRect];
            } else {
                flyTo = MKMapRectUnion(flyTo, [overlay boundingMapRect]);
            }
        }
        
        for (id <MKAnnotation> annotation in annotations) {
            MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
            MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
            if (MKMapRectIsNull(flyTo)) {
                flyTo = pointRect;
            } else {
                flyTo = MKMapRectUnion(flyTo, pointRect);
            }
        }
        
        // Position the map so that all overlays and annotations are visible on screen.
        map.visibleMapRect = flyTo;

    }
}



#pragma mark MKMapViewDelegate

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    return [kmlParser viewForOverlay:overlay];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    return [kmlParser viewForAnnotation:annotation];
}

@end
