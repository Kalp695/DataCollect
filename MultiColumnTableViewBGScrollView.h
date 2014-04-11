//
//  MultiColumnTableViewBGScrollView.h
//  DataCollect
//
//  Created by liucc on 13-12-25.
//  Copyright (c) 2013年 liucc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MultiColumnTableView.h"

@interface MultiColumnTableViewBGScrollView : UIScrollView

@property(nonatomic,assign)MultiColumnTableView *parent;

-(void)reDraw;

@end
