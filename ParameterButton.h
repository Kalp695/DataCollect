//
//  ParameterButton.h
//  DataCollect
//
//  Created by liucc on 4/17/14.
//  Copyright (c) 2014 liucc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomAnn.h"
@interface ParameterButton : UIButton

@property(nonatomic,strong)CustomAnn *ann;
@property(nonatomic,assign)float x;
@property(nonatomic,assign)float y;

@end
