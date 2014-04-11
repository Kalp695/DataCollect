//
//  NameViewController.m
//  DataCollect
//
//  Created by liucc on 13-12-18.
//  Copyright (c) 2013年 liucc. All rights reserved.
//

#import "NameViewController.h"

@interface NameViewController ()

@end

@implementation NameViewController

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString *)nameString{
    NSString *filePath=[[NSBundle mainBundle]pathForResource:@"animalName" ofType:@"txt"];
    NSString *animalName=[[NSString alloc]initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSArray *resultArray=[animalName componentsSeparatedByString:@"\n"];
    NSMutableArray *nameArray=[[NSMutableArray alloc]init];
    for (NSString *line in resultArray) {
        
        NSArray *bufferArray=[line componentsSeparatedByString:@"\t"];
        //        NSLog(@"%@",[bufferArray firstObject]);
        [nameArray addObject:[bufferArray objectAtIndex:0]];
    }
    for (int i=0; i<nameArray.count; i++) {
        //        NSLog(@"the count is %d",[nameArray count]);
        NSLog(@"the name is :%@",[nameArray objectAtIndex:i]);
    }
    return animalName;
    
    
}

@end
