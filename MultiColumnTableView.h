//
//  MultiColumnTableView.h
//  DataCollect
//
//  Created by liucc on 13-12-26.
//  Copyright (c) 2013年 liucc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef NS_ENUM(NSUInteger, MultiColumnType) {
    MultiColumnTypeInteger,
    MultiColumnTypeFloat,
    MultiColumnTypeDate,
};

typedef NS_ENUM(NSUInteger, GridType) {
    GridTypeOfPlant,
    GridTypeOfAnimal,
};


@protocol MultiTableViewDataSource;

@interface MultiColumnTableView : UIView

@property(nonatomic,assign)GridType gridType;

@property(nonatomic,assign)CGFloat cellWidth;
@property(nonatomic,assign)CGFloat cellHeight;
@property(nonatomic,assign)CGFloat topHeaderHeight;
@property(nonatomic,assign)CGFloat leftHeaderWidth;
@property(nonatomic,assign)CGFloat sectionHeaderHeight;
@property(nonatomic,assign)CGFloat boldSeperatorLineWidth;
@property(nonatomic,assign)CGFloat normalSeperatorLineWidth;

@property(nonatomic,strong)UIColor *boldSeperatorLineColor;
@property(nonatomic,strong)UIColor *normalSeperatorLineColor;

@property(nonatomic,assign)BOOL leftHeaderEnable;
@property(nonatomic,weak)id<MultiTableViewDataSource> dataSource;


@property(nonatomic,strong)NSMutableArray *bufferArray;
//装载表格内容的array，在初始化时里面的内容全为-1，每个holderArray分为N个（行数）horizonArray
@property(nonatomic,strong)NSMutableArray *holderArray;
@property(nonatomic,strong)NSMutableArray *horizonArray;



-(void)reloadData;
@end

@protocol MultiTableViewDataSource <NSObject>

@required
-(NSArray *)arrayDataForTopHeaderInTableView:(MultiColumnTableView *)tableView;
-(NSArray *)arrayDataForLeftHeaderInTableView:(MultiColumnTableView *)tableView InSection:(NSUInteger)section;
-(NSArray *)arrayDataForContentInTableView:(MultiColumnTableView *)tableView InSection:(NSUInteger)section;

@optional
-(NSUInteger)numberOfSectionsInTableView:(MultiColumnTableView *)tableView;

-(CGFloat)tableView:(MultiColumnTableView *)tableView contentTableCellWidth:(NSUInteger)column;

-(CGFloat)tableview:(MultiColumnTableView *)tableView cellHeightInRow:(NSUInteger)row InSection:(NSUInteger)section;

-(CGFloat)topHeaderHeightInTableView:(MultiColumnTableView *)tableView;

-(UIColor *)tableView:(MultiColumnTableView *)tableView bgColorInSection:(NSUInteger)section Inrow:(NSUInteger)row InColumn:(NSUInteger)column;

-(UIColor *)tableView:(MultiColumnTableView *)tableView headerBgColorInColumn:(NSUInteger)column;




@end
