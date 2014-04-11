//
//  UIView+MultiColumnTableView.h
//  DataCollect
//
//  Created by liucc on 13-12-25.
//  Copyright (c) 2013年 liucc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (MultiColumnTableView)

-(void)addBottomLineWithWidth:(CGFloat)width bgColor:(UIColor*)color;

-(UIView *)addVerticalLineWithWidth:(CGFloat)width bgColor:(UIColor *)color atX:(CGFloat)x;

@end
