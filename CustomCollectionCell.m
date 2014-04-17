//
//  CustomCollectionCell.m
//  DataCollect
//
//  Created by liucc on 13-12-24.
//  Copyright (c) 2013年 liucc. All rights reserved.
//

#import "CustomCollectionCell.h"
#import "CustomCellBackground.h"
#import <CoreText/CoreText.h>


@implementation CustomCollectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.label.hidden=YES;
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
        self.label.hidden=YES;
        
        
//        YLLabel *textLabel=[[YLLabel alloc]initWithFrame:self.label];
//        [textLabel setText: @"  青海湖鸟岛，因岛上栖息数以十万计的候鸟而得名。它们真实的名字，西边小岛叫海西山，又叫小西山，也叫蛋岛；东边的大岛叫海西皮。"];
//        textLabel.backgroundColor=[UIColor lightGrayColor];
//        textLabel.textColor=[UIColor darkGrayColor];
//        textLabel.font=[UIFont systemFontOfSize:10.0f];
    }
    return self;
}
-(void)atmoicLabel{
    YLLabel *yLabel=[[YLLabel alloc]initWithFrame:self.label.frame];
    self.label.hidden=YES;
    [yLabel setText:self.label.text];
    [self addSubview:yLabel];

}

@end
