//
//  FileColViewController.h
//  DataCollect
//
//  Created by liucc on 13-12-24.
//  Copyright (c) 2013年 liucc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, GridType) {
    GridTypeForPlant,
    GridTypeForAnimal,
    GridTypeForTrack,
    GridTypeForSearch
};

@interface FileColViewController : UICollectionViewController

@property(nonatomic,assign)GridType gridType;
@property(nonatomic,strong)NSFileManager *fileManager;
@property(nonatomic,strong)NSString *documnetPath;
@property(nonatomic,strong)NSString *listPath;

@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentalBtn;
- (IBAction)switchBySeg:(id)sender;



@end
