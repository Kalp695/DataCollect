//
//  SearchViewController.h
//  DataCollect
//
//  Created by liucc on 3/26/14.
//  Copyright (c) 2014 liucc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchViewController : UICollectionViewController<UICollectionViewDataSource,UICollectionViewDelegate>


@property(nonatomic,strong)NSMutableArray *dataSourceArray;

@property(nonatomic,strong)NSMutableArray *downLoadArray;

@property(nonatomic,strong)NSMutableArray *downLoadedArray;

@property(nonatomic,strong)NSMutableArray *willShowKMLArray;

@end
