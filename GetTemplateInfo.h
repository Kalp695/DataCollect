//
//  GetTemplateInfo.h
//  DataCollect
//
//  Created by liucc on 14-1-2.
//  Copyright (c) 2014年 liucc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TemplateInfo.h"

@interface GetTemplateInfo : NSObject


-(NSMutableArray *)getDataArray;
-(NSMutableArray *)getTemInfoFromTp;
-(NSMutableArray *)getAniTemInfoFromTp;
-(NSMutableArray *)getAnidTemInfoFromTp;
-(void)logNodeArray;


+(GetTemplateInfo *)templateAccess;
@end
