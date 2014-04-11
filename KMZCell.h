//
//  KMZCell.h
//  DataCollect
//
//  Created by liucc on 3/28/14.
//  Copyright (c) 2014 liucc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KMZCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;

@property (strong, nonatomic) IBOutlet UILabel *authorLabel;

@property (strong, nonatomic) IBOutlet UILabel *startTimeLabel;

@property (strong, nonatomic) IBOutlet UILabel *endTimeLabel;

@property (strong, nonatomic) IBOutlet UILabel *sizeLabel;

@end
