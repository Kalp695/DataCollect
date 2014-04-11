//
//  MultiColumnTableViewBGScrollView.m
//  DataCollect
//
//  Created by liucc on 13-12-25.
//  Copyright (c) 2013年 liucc. All rights reserved.
//

#import "MultiColumnTableViewBGScrollView.h"
#import "UIView+MultiColumnTableView.h"

@implementation MultiColumnTableViewBGScrollView{
    NSMutableArray *lines;
}
@synthesize parent;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)reDraw{
    if (lines==nil) {
        lines=[[NSMutableArray alloc]initWithCapacity:10];
    }
    for (UIView *view in lines) {
        [view removeFromSuperview];
    }
    [lines removeAllObjects];
    
    UIView *hideView=[[UIView alloc]initWithFrame:CGRectMake(0.0f-parent.normalSeperatorLineWidth, 0, parent.normalSeperatorLineWidth, self.bounds.size.height)];
    hideView.backgroundColor=parent.normalSeperatorLineColor;
    hideView.autoresizingMask=UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
    [self addSubview:hideView];
    [lines addObject:hideView];
    
    UIView *line=nil;
    CGFloat x=0.0f;
    NSUInteger columnCount=[parent.dataSource arrayDataForTopHeaderInTableView:parent].count;
    for (int i=0; i<columnCount; i++) {
        CGFloat width;
        if ([parent.dataSource respondsToSelector:@selector(tableView:contentTableCellWidth:)]) {
            width=[parent.dataSource tableView:parent contentTableCellWidth:i];
        }else{
            width=parent.cellWidth;
        }
        
        x += width+parent.normalSeperatorLineWidth;
        
        line=[self addVerticalLineWithWidth:parent.normalSeperatorLineWidth bgColor:parent.normalSeperatorLineColor atX:x];
        [lines addObject:line];
    }
    
}

-(void)dealloc{
    lines=nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
