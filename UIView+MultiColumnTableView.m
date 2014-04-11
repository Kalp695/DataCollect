//
//  UIView+MultiColumnTableView.m
//  DataCollect
//
//  Created by liucc on 13-12-25.
//  Copyright (c) 2013年 liucc. All rights reserved.
//

#import "UIView+MultiColumnTableView.h"

@implementation UIView (MultiColumnTableView)

-(void)addBottomLineWithWidth:(CGFloat)width bgColor:(UIColor *)color{
    CGRect frame=self.frame;
    frame.size.height +=width;
    self.frame=frame;
    
    UIView *bottomLine=[[UIView alloc]initWithFrame:CGRectMake(0.0, self.frame.size.height-width, self.frame.size.width, width)];
    bottomLine.backgroundColor=color;
    bottomLine.autoresizingMask=UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleTopMargin;
    
    [self addSubview:bottomLine];
}

-(UIView *)addVerticalLineWithWidth:(CGFloat)width bgColor:(UIColor *)color atX:(CGFloat)x{
    UIView *line=[[UIView alloc]initWithFrame:CGRectMake(x, 0.0f, width, self.bounds.size.height)];
    line.backgroundColor=color;
    line.autoresizingMask=UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
    [self addSubview:line];
    return line;
}

@end
