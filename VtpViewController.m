//
//  VtpViewController.m
//  DataCollect
//
//  Created by liucc on 14-1-2.
//  Copyright (c) 2014年 liucc. All rights reserved.
//

#import "VtpViewController.h"
#import "MultiColumnTableView.h"
#import <DDXML.h>
#import "TemplateInfo.h"
#import "NSString+EncodingUTF8Additions.h"
#import "SSZipArchive.h"
#import "Util.h"
#import "UIView+MultiColumnTableView.h"
#import "UIImage+CS_Extention.h"


@interface VtpViewController ()<MultiTableViewDataSource>{
    NSMutableArray *headData;
    NSMutableArray *leftTableData;
    NSMutableArray *rightTableData;
}
@property(nonatomic,strong)NSString *path;
@property(nonatomic,strong)MultiColumnTableView *tableView;


@end

@implementation VtpViewController

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
    [self getHeadDataArray];
    [self getLeftTablePlace];
    [self getRightTablePlace];
    self.tableView=[[MultiColumnTableView alloc]initWithFrame:CGRectInset(self.view.bounds, 5.0f, 5.0f)];
    CGRect frame=self.tableView.frame;
    frame.origin.y += self.navigationController.navigationBar.frame.size.height;
    self.tableView.frame=frame;
    self.tableView.leftHeaderEnable=YES;
    self.tableView.dataSource=self;
    self.tableView.gridType=[Util getCurrentUserInfo].userRole;
    [self.view addSubview:self.tableView];

    if (self.ifExistFile) {
        // getDataFromFile:holderArray  Data.txt
        NSString *dataPath=[self.path stringByAppendingPathComponent:@"VtpData.txt"];
        NSMutableArray *holderArray=[[NSMutableArray alloc]initWithContentsOfFile:dataPath];
       self.tableView.holderArray=holderArray;
    }else{
        //initData
    }
    
    NSLog(@"username is %@",[Util getCurrentUserInfo].userName);
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    NSString *dataPath=[self.path stringByAppendingPathComponent:@"VtpData.txt"];
    [self.tableView.holderArray writeToFile:dataPath atomically:YES];
    [self writeDataToXml];
    [self createZip];
    [self screenShot];
}





#pragma mark -Accessor
-(NSString *)path{
    if (!_path) {
        NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *listPath=[[paths firstObject]stringByAppendingPathComponent:@"plantList"];
        _path=[listPath stringByAppendingPathComponent:self.dirTitle];
    }
    return _path;
}
-(BOOL)ifExistFile{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSArray *dirs=[fileManager contentsOfDirectoryAtPath:self.path error:nil];
    NSMutableArray *temDirs=[NSMutableArray arrayWithArray:dirs];
    if ([temDirs indexOfObject:@".DS_Store"]!=NSNotFound) {
        [temDirs removeObject:@".DS_Store"];
    }
    if ([temDirs containsObject:@"VtpData.txt"]) {
        return YES;
    }else{
        return NO;
    }
}
-(void)getDataFromFile{
    //从VtpData.txt 初始化一个数组作为表格的holderArray
    //headData
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
-(void)getLeftTablePlace{
    leftTableData=[NSMutableArray arrayWithCapacity:20];
    NSMutableArray *one=[NSMutableArray arrayWithCapacity:19];
    for (int i=0; i<19; i++) {
        [one addObject:[NSString stringWithFormat:@"%d",i]];
    }
    [leftTableData addObject:one];
}
-(void)getRightTablePlace{
    rightTableData =[NSMutableArray arrayWithCapacity:20];
    NSMutableArray *oneR=[NSMutableArray arrayWithCapacity:19];
    for (int i=0; i<19; i++) {
        NSMutableArray *ary=[NSMutableArray arrayWithCapacity:19];
        for (int j=0; j<headData.count; j++) {
            [ary addObject:[NSString stringWithFormat:@"id:%d-%d",i,j]];
        }
        [oneR addObject:ary];
    }
    [rightTableData addObject:oneR];
}

#pragma mark -MultiTableViewDataSource
-(NSArray *)arrayDataForTopHeaderInTableView:(MultiColumnTableView *)tableView{
    return [headData copy];
}
-(NSArray *)arrayDataForLeftHeaderInTableView:(MultiColumnTableView *)tableView InSection:(NSUInteger)section{
    return [leftTableData objectAtIndex:section];
}
-(NSArray *)arrayDataForContentInTableView:(MultiColumnTableView *)tableView InSection:(NSUInteger)section{
    return [rightTableData objectAtIndex:section];
}
-(NSUInteger)numberOfSectionsInTableView:(MultiColumnTableView *)tableView{
    return [leftTableData count];
}
-(CGFloat)tableView:(MultiColumnTableView *)tableView contentTableCellWidth:(NSUInteger)column{
    return 180.0f;
}
-(CGFloat)tableview:(MultiColumnTableView *)tableView cellHeightInRow:(NSUInteger)row InSection:(NSUInteger)section{
    return 55.0f;
}
-(UIColor *)tableView:(MultiColumnTableView *)tableView bgColorInSection:(NSUInteger)section InRow:(NSUInteger)row InColumn:(NSUInteger)column{
    return  [UIColor clearColor];
}
- (UIColor *)tableView:(MultiColumnTableView *)tableView headerBgColorInColumn:(NSUInteger)column {
//    if (column == -1) {
//        return [UIColor redColor];
//    }else if (column == 1) {
//        return [UIColor grayColor];
//    }
    return [UIColor clearColor];
}


-(void)writeDataToXml{
    DDXMLElement *ele_root=[DDXMLElement elementWithName:@"list"];
    
    NSMutableArray *templateInfoArray=[[GetTemplateInfo templateAccess]getTemInfoFromTp];
    NSMutableArray *proceedTemArray=[[NSMutableArray alloc]init];
    for (int i=0; i<templateInfoArray.count; i++) {
        TemplateInfo *data=[templateInfoArray objectAtIndex:i];
        if (data.ifDisplay) {
            [proceedTemArray addObject:data];
        }
    }
    for (int i=0; i<self.tableView.holderArray.count; i++) {
        DDXMLElement *ele_node=[DDXMLElement elementWithName:@"node"];
        for (int j=0; j<proceedTemArray.count; j++) {
            TemplateInfo *data=[proceedTemArray objectAtIndex:j];
            NSString *key=data.key;
            [ele_node addAttribute:[DDXMLNode attributeWithName:[NSString stringWithFormat:@"%@ %d",key,j] stringValue:[[self.tableView.holderArray objectAtIndex:i]objectAtIndex:j]]];
        }
        [ele_root addChild:ele_node];
    }
    NSString *fileName=[NSString stringWithFormat:@"t_siyfi_vtp_%@_%@.xml",[Util getCurrentUserInfo].userName, self.dirTitle];
    //转换编码
    NSString *xmlString =[NSString replaceUnicode: [ele_root XMLString]];
    NSMutableString *mutableXmlString=[xmlString mutableCopy];
    NSString *path=[self.path stringByAppendingPathComponent:fileName];
    [mutableXmlString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
}
-(void)createZip{
    NSString *zipName=[NSString stringWithFormat:@"t_siyfi_vssb&vtp_%@.zip",self.dirTitle];
    NSString *zipPath=[self.path stringByAppendingPathComponent:zipName];
    NSString *fileName1=[NSString stringWithFormat:@"t_siyfi_vssb_%@_%@.xml",[Util getCurrentUserInfo].userName, self.dirTitle];
    NSString *fileName2=[NSString stringWithFormat:@"t_siyfi_vtp_%@_%@.xml",[Util getCurrentUserInfo].userName, self.dirTitle];
    NSString *file1Path=[self.path stringByAppendingPathComponent:fileName1];
    NSString *file2Path=[self.path stringByAppendingPathComponent:fileName2];
    NSArray *inputPaths=[NSArray arrayWithObjects:file1Path,file2Path, nil];
    [SSZipArchive createZipFileAtPath:zipPath withFilesAtPaths:inputPaths];
}

-(void)screenShot{
    UIWindow *screenWindow = [[UIApplication sharedApplication] keyWindow];
    UIGraphicsBeginImageContext(screenWindow.frame.size);
    [screenWindow.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *resultImg=[UIImage imageWithCGImage:CGImageCreateWithImageInRect(screenshot.CGImage, CGRectMake(self.navigationController.navigationBar.frame.size.height+20, self.view.frame.origin.y+55, 748, 1024))];
    
    NSData *screenshotPNG = UIImagePNGRepresentation([resultImg imageRotatedByDegrees:-90]);
        NSError *error = nil;
    [screenshotPNG writeToFile:[self.path stringByAppendingPathComponent:@"screenshot.png"] options:NSAtomicWrite error:&error];

}



@end
