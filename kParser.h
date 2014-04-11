//
//  kParser.h
//  DataCollect
//
//  Created by liucc on 4/10/14.
//  Copyright (c) 2014 liucc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class KMLPlacemark1;
@class KMLStyle1;

@interface kParser : NSObject <NSXMLParserDelegate> {
    NSMutableDictionary *_styles;
    NSMutableArray *_placemarks;
    
    KMLPlacemark1 *_placemark;
    KMLStyle1 *_style;
    
    NSXMLParser *_xmlParser;
}

- (id)initWithURL:(NSURL *)url;
- (void)parseKML;

@property (nonatomic, readonly) NSArray *overlays;
@property (nonatomic, readonly) NSArray *points;

- (MKAnnotationView *)viewForAnnotation:(id <MKAnnotation>)point;
- (MKOverlayView *)viewForOverlay:(id <MKOverlay>)overlay;

@end
