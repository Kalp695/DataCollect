//
//  AutoFieldViewController.m
//  DataCollect
//
//  Created by liucc on 13-12-18.
//  Copyright (c) 2013年 liucc. All rights reserved.
//

#import "AutoFieldViewController.h"

@interface AutoFieldViewController ()

@property(nonatomic,strong)UITextField *tf1;
@property(nonatomic,strong)UITextField *tf2;

@end

@implementation AutoFieldViewController

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
    [self.view addSubview:self.table];
    [self.view addSubview:self.tf1];
    [self.view addSubview:self.tf2];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -Accessors

-(UITextField *)tf1{
    if (!_tf1) {
        _tf1=[[UITextField alloc]initWithFrame:CGRectMake(self.view.frame.origin.x+150, self.view.frame.origin.y+300, 170, 44)];
        _tf1.borderStyle=UITextBorderStyleRoundedRect;
        _tf1.placeholder=@"tf1";
        _tf1.delegate=self;
    }
    return _tf1;
}
-(UITextField *)tf2{
    if (!_tf2) {
        _tf2=[[UITextField alloc]initWithFrame:CGRectMake(self.view.frame.origin.x+150, self.view.frame.origin.y+360, 170, 44)];
        _tf2.placeholder=@"tf2";
        _tf2.delegate=self;
    }
    return _tf2;
}

-(UITableView *)table{
    if (!_table) {
        _table=[[UITableView alloc]initWithFrame:CGRectMake(self.view.frame.origin.x+150, self.view.frame.origin.y+420, 170, 230)];
        _table.delegate=self;
        _table.dataSource=self;
        _table.hidden=YES;
    }
    return _table;
}

#pragma mark -UITableViewDelegate and Datasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 30;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier=@"cell";
    UITableViewCell *cell=(UITableViewCell *)[self.table dequeueReusableCellWithIdentifier:identifier];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.selectionStyle=UITableViewCellSelectionStyleBlue;
    }
    NSString *test=[NSString stringWithFormat:@"test%d",indexPath.row];
    cell.textLabel.text=test;
    return cell;
}

#pragma mark -UITextfieldDelegates

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    NSLog(@"the textField is ready to be tapped");
    
    //将tableView 显示在该textField之下,并reload
    [self updateTabel:textField];
    [self showTabel];
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    NSLog(@"the textField have been tapped already");
    [self hideTabel];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(void)showTabel{
    self.table.hidden=NO;
}
-(void)hideTabel{
    self.table.hidden=YES;
}

-(void)updateTabel:(UITextField *)textField{
    CGRect frame=CGRectMake(textField.frame.origin.x, textField.frame.origin.y+textField.frame.size.height, 170, 230);
    self.table.frame=frame;
    [self.table reloadData];
}


@end
