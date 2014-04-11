//
//  VssbViewController.h
//  DataCollect
//
//  Created by liucc on 14-1-2.
//  Copyright (c) 2014年 liucc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface VssbViewController : UIViewController<CLLocationManagerDelegate>


@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *textFieldArray;

@property (strong, nonatomic) IBOutlet UISwitch *switchBtn;

@property (strong, nonatomic) IBOutlet UIImageView *nearPicView;

@property (strong, nonatomic) IBOutlet UIImageView *farerPivView;

- (IBAction)switchAction:(id)sender;

@property(nonatomic,assign)BOOL isUploaded;

//

//目录的名称
@property(nonatomic,strong)NSString *dirTitle;
//在该目录下是否存在已创建的文件
@property(nonatomic,assign)BOOL ifExistFile;
//数据源
@property(nonatomic,strong)NSMutableArray *dataArray;


@end
