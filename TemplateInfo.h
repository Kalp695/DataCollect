//
//  TemplateInfo.h
//  DataCollect
//
//  Created by liucc on 14-1-2.
//  Copyright (c) 2014年 liucc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TemplateInfo : NSObject

@property(nonatomic,strong)NSString *key;
@property(nonatomic,strong)NSString *name;

@property(nonatomic,strong)NSString *attribute;
@property(nonatomic,strong)NSString *value;
@property(nonatomic,assign)BOOL ifEmpty;
@property(nonatomic,assign)BOOL ifDisplay;

@end
