//
//  UserEntity.h
//  DataCollect
//
//  Created by liucc on 1/10/14.
//  Copyright (c) 2014 liucc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, UserRole) {
    UserRoleForPlant,
    UserRoleForAnimal
};

@interface UserEntity : NSObject

@property(nonatomic,strong)NSString *userName;
@property(nonatomic,assign)BOOL isLogin;
@property(nonatomic,assign)UserRole userRole;

@end
