//
//  CustomCollectionCell.h
//  DataCollect
//
//  Created by liucc on 13-12-24.
//  Copyright (c) 2013年 liucc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCollectionCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *image;
@property (strong, nonatomic) IBOutlet UILabel *label;
@property (nonatomic,assign)BOOL isUploaded;

@property (strong, nonatomic) IBOutlet UIImageView *uploadFlag;




@end