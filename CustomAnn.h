//
//  CustomAnn.h
//  DataCollect
//
//  Created by liucc on 4/17/14.
//  Copyright (c) 2014 liucc. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface CustomAnn : MKPointAnnotation

@property(nonatomic,strong)NSString *videoPath;
@property(nonatomic,strong)NSString *audioPath;
@property(nonatomic,strong)NSString *imgPath;

@end
