//
//  MKPointAnnotation+AdditionalInfo.h
//  DataCollect
//
//  Created by liucc on 3/6/14.
//  Copyright (c) 2014 liucc. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKPointAnnotation (AdditionalInfo)


@property(nonatomic,strong)NSString *imagePath;
@property(nonatomic,strong)NSString *videoPath;
@property(nonatomic,strong)NSString *audioPath;

@end
