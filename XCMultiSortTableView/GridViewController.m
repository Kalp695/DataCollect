//
//  GridViewController.m
//  DataCollect
//
//  Created by liucc on 13-12-19.
//  Copyright (c) 2013年 liucc. All rights reserved.
//

#import "GridViewController.h"
#import "GetTemplateInfo.h"

@interface GridViewController ()<MultiTableViewDataSource>{
    NSMutableArray *headData;
    NSMutableArray *leftTableData;
    NSMutableArray *rightTableData;
}

@property(nonatomic,strong)NSFileManager *fileManager;
@property(nonatomic,strong)NSString *documnetPath;
@property(nonatomic,strong)NSString *listPath;


@end

@implementation GridViewController
//
//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initData];
    MultiColumnTableView *tableView=[[MultiColumnTableView alloc]initWithFrame:CGRectInset(self.view.bounds, 5.0f, 5.0f)];
    tableView.leftHeaderEnable=YES;
    tableView.dataSource=self;
    [self.view addSubview:tableView];
//    
//    [self writeData:tableView];
//    [self accessData];
//    
    
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)initData{
//    headData=[NSMutableArray arrayWithCapacity:12];
//    NSArray *buffer=@[@"植物种类",@"层次",@"植株平均高度",@"株数",@"胸径",@"投影盖度",@"生活型",@"枝叶型",@"生活力",@"物候相",@"备注"];
//    headData=[NSMutableArray arrayWithArray:buffer];

    [self getHeadDataArray];
    leftTableData=[NSMutableArray arrayWithCapacity:10];
    NSMutableArray *one=[NSMutableArray arrayWithCapacity:7];
    for (int i=0; i<7; i++) {
        [one addObject:[NSString stringWithFormat:@"%d",i]];
    }
    [leftTableData addObject:one];
    
    rightTableData =[NSMutableArray arrayWithCapacity:10];
    NSMutableArray *oneR=[NSMutableArray arrayWithCapacity:7];
    for (int i=0; i<7; i++) {
        NSMutableArray *ary=[NSMutableArray arrayWithCapacity:7];
        for (int j=0; j<11; j++) {
            [ary addObject:[NSString stringWithFormat:@"id:%d-%d",i,j]];
        }
        [oneR addObject:ary];
        
    }
    [rightTableData addObject:oneR];
}

-(void)getHeadDataArray{
    headData=[[NSMutableArray alloc]init];
    GetTemplateInfo *templateAccess=[GetTemplateInfo templateAccess];
    NSMutableArray *templateArray=[templateAccess getTemInfoFromTp];
    for (TemplateInfo *data in templateArray) {
        if (data.ifDisplay) {
            [headData addObject:data.name];
        }
    }
}



#pragma mark -XCMultiTableViewDataSource

-(NSArray *)arrayDataForTopHeaderInTableView:(MultiColumnTableView *)tableView{
    return [headData copy];
}

-(NSArray *)arrayDataForLeftHeaderInTableView:(MultiColumnTableView *)tableView InSection:(NSUInteger)section{
    return [leftTableData objectAtIndex:section];
    
}

-(NSArray *)arrayDataForContentInTableView:(MultiColumnTableView *)tableView InSection:(NSUInteger)section{
    return [rightTableData objectAtIndex:section];
}


- (NSUInteger)numberOfSectionsInTableView:(MultiColumnTableView *)tableView {
    return [leftTableData count];
}

-(CGFloat)tableView:(MultiColumnTableView *)tableView contentTableCellWidth:(NSUInteger)column{
    if (column==0) {
        return 500.0f;
    }
    return 250.0f;
}
-(CGFloat)tableView:(MultiColumnTableView *)tableView cellHeightInRow:(NSUInteger)row InSection:(NSUInteger)section{
    if (section==0) {
        return 60.0f;
    }else{
        return 30.0f;
    }
}

-(UIColor *)tableView:(MultiColumnTableView *)tableView bgColorInSection:(NSUInteger)section InRow:(NSUInteger)row InColumn:(NSUInteger)column{
    return  [UIColor clearColor];
}
- (UIColor *)tableView:(MultiColumnTableView *)tableView headerBgColorInColumn:(NSUInteger)column {
    if (column == -1) {
        return [UIColor redColor];
    }else if (column == 1) {
        return [UIColor grayColor];
    }
    return [UIColor clearColor];
}


#pragma mark -Accessors
-(NSFileManager *)fileManager{
    if (!_fileManager) {
        _fileManager=[NSFileManager defaultManager];
    }
    return _fileManager;
}
-(NSString *)documnetPath{
    if (!_documnetPath) {
        NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        _documnetPath=[paths firstObject];
    }
    return _documnetPath;
}
-(NSString *)listPath{
    if (!_listPath) {
        _listPath=[self.documnetPath stringByAppendingPathComponent:@"list"];
    }
    return _listPath ;
}






#pragma mark -LifeCycle
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    
}
-(void)writeData:(MultiColumnTableView *)tableView{
//    NSMutableData *writer=[[NSMutableData alloc]init];
    NSString *testTxt=[self.listPath stringByAppendingPathComponent:@"textTxt.txt"];
    [tableView.holderArray writeToFile:testTxt atomically:YES];
    
}
-(void)accessData{
    NSString *testTxt=[self.listPath stringByAppendingPathComponent:@"textTxt.txt"];

    NSArray *testArray=[[NSArray alloc]initWithContentsOfFile:testTxt];
    NSLog(@"%@",testArray);
    
}






































@end
