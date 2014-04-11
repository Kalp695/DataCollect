//
//  SearchView.m
//  DataCollect
//
//  Created by liucc on 3/19/14.
//  Copyright (c) 2014 liucc. All rights reserved.
//

#import "SearchView.h"

@implementation SearchView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    self=[super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}
-(void)setup{
    [[NSBundle mainBundle]loadNibNamed:@"SearchView" owner:self options:nil];
    [self addSubview:self.view];
    self.backgroundColor=[UIColor clearColor];
    //add the switchBtn
    [self initSwipeBtn];
}
-(IBAction)switchSelf:(id)sender{
}

-(void)initSwipeBtn{
    UIButton *button=[[UIButton alloc]initWithFrame:CGRectMake(220, 320, 128, 128)];
//    UIImageView *imageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"swipe_right"]];
    [button setImage:[UIImage imageNamed:@"swipe_right"] forState:UIControlStateNormal];
    [self addSubview:button];
    [button addTarget:self action:@selector(swipeView) forControlEvents:UIControlEventTouchUpInside];
}
-(void)swipeView{
    if (self.isShow) {
        //收缩
        CGRect frame=self.frame;
        frame.origin.x -=320;
        
        CGContextRef context=UIGraphicsGetCurrentContext();
        [UIView beginAnimations:@"HideSearchView" context:context];
        [UIView setAnimationDuration:0.4];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        
        [self setFrame:frame];
        
        [UIView commitAnimations];
        
        self.isShow=NO;
    }else{
        //弹出
        CGRect frame=self.frame;
        frame.origin.x +=320;
        
        CGContextRef context=UIGraphicsGetCurrentContext();
        [UIView beginAnimations:@"ShowSearchView" context:context];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.7];
        
        [self setFrame:frame];
        
        [UIView commitAnimations];
        
        self.isShow=YES;
    }

}



- (IBAction)searhByAuthor:(id)sender {
    [self.delegate showListByAuthor:self.authorField.text];
}

-(IBAction)searchByKeyplace:(id)sender{
    [self.delegate showListByKeyplace:self.keyPlaceField.text];
}

-(IBAction)searchByName:(id)sender{
    [self.delegate showListByName:self.nameField.text];
}
@end
