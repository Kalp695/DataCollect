//
//  Util.m
//  DataCollect
//
//  Created by liucc on 1/14/14.
//  Copyright (c) 2014 liucc. All rights reserved.
//

#import "Util.h"

@implementation Util

+(UserEntity *)getCurrentUserInfo{
    static dispatch_once_t pred;
    static UserEntity *currentUser;
    dispatch_once(&pred,^{
        currentUser=[[UserEntity alloc]init];
    });
    return currentUser;
}

@end
