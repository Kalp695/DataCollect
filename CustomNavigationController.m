//
//  CustomNavigationController.m
//  DataCollect
//
//  Created by liucc on 1/13/14.
//  Copyright (c) 2014 liucc. All rights reserved.
//

#import "CustomNavigationController.h"

@interface CustomNavigationController ()

@end

@implementation CustomNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationBar addSubview:self.toolBar];
	// Do any additional setup after loading the view.

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(UIToolbar *)toolBar{
    if (!_toolBar) {
        NSMutableArray *toolBarItems;
        UIBarButtonItem *delItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(trashItemClicked)];
        UIBarButtonItem *flexSpace=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
        flexSpace.width=30;
        UIBarButtonItem *uploadItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(uploadItemClicked)];
        toolBarItems=[[NSMutableArray alloc]initWithObjects:delItem,flexSpace,uploadItem, nil];
        _toolBar=[[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
        _toolBar.barTintColor=[UIColor clearColor];
        _toolBar.backgroundColor=[UIColor clearColor];
        _toolBar.barStyle=UIBarStyleBlackOpaque;
        [_toolBar setItems:toolBarItems animated:NO];
        
    }
    return _toolBar;
}
-(void)trashItemClicked{
    [self.cDelegate trashItemClicked];

}
-(void)uploadItemClicked{
    [self.cDelegate uploadItemClicked];
}
@end
