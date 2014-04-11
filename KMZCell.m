//
//  KMZCell.m
//  DataCollect
//
//  Created by liucc on 3/28/14.
//  Copyright (c) 2014 liucc. All rights reserved.
//

#import "KMZCell.h"
#import "CustomCellBackground.h"
@implementation KMZCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
-(id)initWithCoder:(NSCoder *)aDecoder{
    self=[super initWithCoder:aDecoder];
    if (self) {
        CustomCellBackground *bacView=[[CustomCellBackground alloc]initWithFrame:CGRectZero];
        self.selectedBackgroundView=bacView;
    }
    return self;
}
@end
