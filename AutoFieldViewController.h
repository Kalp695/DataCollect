//
//  AutoFieldViewController.h
//  DataCollect
//
//  Created by liucc on 13-12-18.
//  Copyright (c) 2013年 liucc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AutoFieldViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

@property(nonatomic,strong)UITableView *table;


@end
