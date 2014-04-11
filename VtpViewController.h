//
//  VtpViewController.h
//  DataCollect
//
//  Created by liucc on 14-1-2.
//  Copyright (c) 2014年 liucc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TemplateInfo.h"
#import "GetTemplateInfo.h"

@interface VtpViewController : UIViewController

//目录的名称
@property(nonatomic,strong)NSString *dirTitle;
//该目录下是否存在已创建的文件
@property(nonatomic,assign)BOOL ifExistFile;

@property(nonatomic,assign)BOOL isUploaded;


@end
