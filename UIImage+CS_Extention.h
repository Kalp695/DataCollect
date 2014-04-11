//
//  UIImage+CS_Extention.h
//  DataCollect
//
//  Created by liucc on 1/16/14.
//  Copyright (c) 2014 liucc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (CS_Extention)
- (UIImage *)imageAtRect:(CGRect)rect;
- (UIImage *)imageByScalingProportionallyToMinimumSize:(CGSize)targetSize;
- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize;
- (UIImage *)imageByScalingToSize:(CGSize)targetSize;
- (UIImage *)imageRotatedByRadians:(CGFloat)radians;
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;


@end
