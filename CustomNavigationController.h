//
//  CustomNavigationController.h
//  DataCollect
//
//  Created by liucc on 1/13/14.
//  Copyright (c) 2014 liucc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomNavgationDelegate ;

@interface CustomNavigationController : UINavigationController


@property(nonatomic,strong)UIToolbar *toolBar;
@property(nonatomic,strong)id<CustomNavgationDelegate> cDelegate;

@property(nonatomic,strong)UIButton *searchBtn;
@property(nonatomic,strong)UIPickerView *picker;

@end

@protocol CustomNavgationDelegate <NSObject>
@optional
-(void)trashItemClicked;
-(void)uploadItemClicked;


@end