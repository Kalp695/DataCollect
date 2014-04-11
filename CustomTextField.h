//
//  CustomTextField.h
//  DataCollect
//
//  Created by liucc on 13-12-30.
//  Copyright (c) 2013年 liucc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, InputType) {
    InputTypeByDate,
    InputTypeByTable,
    InputTypeByString
};

@interface CustomTextField : UITextField
@property(nonatomic,assign)InputType inputType;
@property(nonatomic,assign)NSInteger idenHorizon;
@property(nonatomic,assign)NSInteger idenVertical;
@property(nonatomic,strong)NSIndexPath *indexPath;

@end
