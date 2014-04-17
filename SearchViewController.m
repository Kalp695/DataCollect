//
//  SearchViewController.m
//  DataCollect
//
//  Created by liucc on 3/26/14.
//  Copyright (c) 2014 liucc. All rights reserved.
//

#import "SearchViewController.h"
#import "CustomNavigationController.h"
#import "KMZCell.h"
#import <AFNetworking.h>
#import "SSZipArchive.h"
#import <DDXML.h>
#import <DDXMLElementAdditions.h>
#import "NSString+EncodingUTF8Additions.h"
#import "kmViewController.h"
#import "MBProgressHUD.h"

@interface SearchViewController ()<UIPickerViewDataSource,UIPickerViewDelegate,MBProgressHUDDelegate>
@property(nonatomic,strong)NSArray *searchTypeList;
@property(nonatomic,strong)NSString *searchTypeStr;
@property(nonatomic,strong)UIToolbar *toolBar;
@property(nonatomic,strong)UITextField *textField;
@property(nonatomic,assign)NSInteger serachIden;
@property(nonatomic,strong)UIBarButtonItem *downloadItem;
@property(nonatomic,strong)UIBarButtonItem *showItem;

@property(nonatomic,strong)UISegmentedControl *segement;
@property(nonatomic,strong)NSString *listPath;

@end

@implementation SearchViewController

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
    [self initCollectionView];
    [self receiveNotification];
    [self initRightBtnItem];
    [self initRightBtn];
    [self initSegment];

	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self initPicker];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    CustomNavigationController *navCon=(CustomNavigationController *)self.navigationController;
//    navCon.searchBtn.hidden=NO;
    _toolBar.hidden=YES;
    self.segement.hidden=YES;

}


#pragma mark -Accessors
-(NSMutableArray *)downLoadArray{
    if (!_downLoadArray) {
        _downLoadArray=[@[]mutableCopy];

    }
    return _downLoadArray;
}

-(NSMutableArray *)downLoadedArray{
    if (!_downLoadedArray) {
        _downLoadedArray=[@[]mutableCopy];
    }
    return _downLoadedArray;
}

-(NSMutableArray *)willShowKMLArray{
    if (!_willShowKMLArray) {
        _willShowKMLArray=[@[]mutableCopy];
    }
    return _willShowKMLArray;
}


-(NSString *)listPath{
    if (!_listPath) {
        NSString *docPath=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        _listPath=[docPath stringByAppendingPathComponent:@"dlKmzList"];

    }
    return _listPath;
}
#pragma mark -Private Method

-(void)initPicker{
    CustomNavigationController *navCon=(CustomNavigationController *)self.navigationController;
    navCon.searchBtn.hidden=YES;
    
    
    
    UIPickerView *picker=[[UIPickerView alloc]initWithFrame:CGRectMake(50, -10, 230, 44)];
    picker.showsSelectionIndicator=YES;
    picker.delegate=self;
    picker.dataSource=self;
    
//    [self.view addSubview:picker];
    
    navCon.picker=picker;
    
    
    self.searchTypeList=[[NSArray alloc]initWithObjects:@"请选择查询类型",@"按作者名查询",@"按关键点查询",@"按名称查询",@"划区域查询", nil];
    
    
    NSMutableArray *toolBarItems;
    _textField=[[UITextField alloc]initWithFrame:CGRectMake(280, -10, 180, 44)];
    _textField.borderStyle=UITextBorderStyleBezel;

    
    UIBarButtonItem *item=[[UIBarButtonItem alloc]initWithCustomView:picker];
    UIBarButtonItem *searchItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchBtnClicked)];
    UIBarButtonItem *textInputItem=[[UIBarButtonItem alloc]initWithCustomView:_textField];
    
    
    toolBarItems=[[NSMutableArray alloc]initWithObjects:item,textInputItem,searchItem, nil];
    _toolBar=[[UIToolbar alloc]initWithFrame:CGRectMake(70, -4, 500, 44)];
    _toolBar.barTintColor=[UIColor clearColor];
    _toolBar.backgroundColor=[UIColor clearColor];
    _toolBar.barStyle=UIBarStyleBlackOpaque;
    [_toolBar setItems:toolBarItems animated:NO];
    //还要加一个搜索动作的激活按钮，事件为search,返回数据为searchResults
    
    
    [self.navigationController.navigationBar addSubview:_toolBar];
    
}

-(void)initCollectionView{
    UIEdgeInsets inset=UIEdgeInsetsMake(10, 10, 0, 10);
    self.collectionView.contentInset=inset;
    self.collectionView.allowsSelection=YES;
    self.collectionView.allowsMultipleSelection=YES;
    
    self.dataSourceArray=[@[]mutableCopy];
    
    
}

-(void)searchBtnClicked{
    NSError *error;
//    管理员
    NSLog(@"current txt:%@",self.textField.text);
    //todo :经测试，author不能含空格
    NSString *prefix;
    switch (self.serachIden) {
        case 1:
            prefix=@"http://159.226.15.215:8081/samples/kmz/selectbyauthor.jsp?author=";
            break;
            case 2:
            prefix=@"http://159.226.15.215:8081/samples/kmz/selectbykeysitelist.jsp?keysiteslist=";
            break;
            case 3:
            prefix=@"http://159.226.15.215:8081/samples/kmz/selectbyname.jsp?name=";
            
        default:
            break;
    }
    NSString *urlString=[prefix stringByAppendingString:self.textField.text];
    NSString *encodedURLString=(NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)urlString, NULL, NULL, kCFStringEncodingUTF8));
    NSString *results=[NSString stringWithContentsOfURL:[NSURL URLWithString:encodedURLString] encoding:NSUTF8StringEncoding error:&error];
    self.dataSourceArray=[[results componentsSeparatedByString:@";"]mutableCopy];
    NSLog(@"the:%d",self.dataSourceArray.count);

    [self.collectionView reloadData];
}

-(void)initRightBtn{
        self.navigationItem.rightBarButtonItem=self.downloadItem;

}

-(void)initRightBtnItem{
    self.downloadItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addFileToDownLoad)];
    self.showItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showKMLViewer)];
    
}
-(void)addFileToDownLoad{
    //下载至文件夹并解压
    for (int i=0;i<self.downLoadArray.count;i++) {
        NSString *address=[self.downLoadArray objectAtIndex:i];
        NSString *handeledAddress=[address stringByReplacingOccurrencesOfString:@"\n/var/gpstracks/" withString:@""];
        [self.downLoadArray replaceObjectAtIndex:i withObject:handeledAddress];
    }
    [self downLoadTask:self.downLoadArray];
}

-(void)downLoadTask:(NSMutableArray *)array{
    NSLog(@"%@",array);
//    NSString *docPath=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
//    self.listPath=[docPath stringByAppendingPathComponent:@"dlKmzList"];
    NSFileManager *fileManager=[NSFileManager defaultManager];
    
    
    for (NSString *address in array) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        NSURL *URL=[NSURL URLWithString:[NSString stringWithFormat:@"http://159.226.15.215:8080/gpstracks/%@.kmz",address]];

        
        NSLog(@"%@",URL);
        NSURLRequest *request=[NSURLRequest requestWithURL:URL];
        
        //hud指示图
        MBProgressHUD *hud=[[MBProgressHUD alloc]initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:hud];
        hud.delegate=self;
        hud.labelText=@"下载中";
        hud.detailsLabelText=@"downloading data";
        hud.square=YES;
        
        [hud showAnimated:YES whileExecutingBlock:^{
            NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                NSURL *documentsDirectoryPath = [NSURL fileURLWithPath:self.listPath];
                return [documentsDirectoryPath URLByAppendingPathComponent:[response suggestedFilename]];
            } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                NSLog(@"File downloaded to: %@", filePath);
                //可以在这里进行解压工作
                NSString *kmzPath=[self.listPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.kmz",address]];
                
                [SSZipArchive unzipFileAtPath:kmzPath toDestination:self.listPath];
                [fileManager removeItemAtPath:kmzPath error:nil];
                
                
            }];
            [downloadTask resume];
        }completionBlock:^{
            [hud removeFromSuperview];
        }];

        
    }
}

-(void)showKMLViewer{
    [self performSegueWithIdentifier:@"ShowKMLViewer" sender:nil];
}
-(void)initSegment{
    self.segement=[[UISegmentedControl alloc]initWithFrame:CGRectMake(550.0f, 8.0f, 180.0f, 30.0f)];
    [self.segement insertSegmentWithTitle:@"查询列表" atIndex:0 animated:YES];
    [self.segement insertSegmentWithTitle:@"已下载列表" atIndex:1 animated:YES];
    self.segement.selectedSegmentIndex=0;
    [self.navigationController.navigationBar addSubview:self.segement];
    [self.segement addTarget:self action:@selector(switchCol) forControlEvents:UIControlEventValueChanged];
    
}
-(void)switchCol{
    
    
    if (self.segement.selectedSegmentIndex==0) {
        self.navigationItem.rightBarButtonItem=self.downloadItem;

    }else{
        self.navigationItem.rightBarButtonItem=self.showItem;
        //downloadedArray读取，
        //collectionView reload;
        [self.downLoadedArray removeAllObjects];
        NSFileManager *fileManager=[NSFileManager defaultManager];
        NSArray *dirs=[fileManager contentsOfDirectoryAtPath:self.listPath error:nil];
        for (NSString *address in dirs) {
            NSMutableArray *dirInfo=[@[]mutableCopy];
            //        NSMutableArray *handledDirInfo=[@[]mutableCopy]
            NSString *detailPath=[self.listPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/TrackDetail.xml",address]];
            NSData *sourceData=[NSData dataWithContentsOfFile:detailPath];
            DDXMLDocument *xmlDoc=[[DDXMLDocument alloc]initWithData:sourceData options:0 error:nil];
            NSArray *items=[xmlDoc nodesForXPath:@"//trackdetail" error:nil];
            for (DDXMLElement *item in items) {
                [dirInfo addObject:[item elementForName:@"name"].stringValue];
                [dirInfo addObject:[item elementForName:@"author"].stringValue];
                [dirInfo addObject:[item elementForName:@"starttime"].stringValue];
                [dirInfo addObject:[item elementForName:@"endtime"].stringValue];
                [dirInfo addObject:[item elementForName:@"length"].stringValue];
                [dirInfo addObject:[item elementForName:@"maxaltitude"].stringValue];
                [dirInfo addObject:[item elementForName:@"keysiteslist"].stringValue];
                
            }
            //再加入一个字符串表示其地址，以在后面方便定位
            [dirInfo addObject:address];
            for (int i=0;i<dirInfo.count;i++) {
                NSString *item=[dirInfo objectAtIndex:i];
                NSString *info=[NSString replaceUnicode:item];
                //            NSLog(@"info:%@",info);
                [dirInfo replaceObjectAtIndex:i withObject:info];
            }
            //        NSLog(@"detailpath:%@",address);
            [self.downLoadedArray addObject:dirInfo];
        }
        
        //    NSLog(@"%@",self.downLoadedArray);
//        //经测试，在由目录数生成的array中，第一个元素为空，故暂时删掉第一个元素先，不知真机是否存在该问题
//        [self.downLoadedArray removeObjectAtIndex:0];
        [self.collectionView reloadData];

    }
    
}


#pragma mark -UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (self.segement.selectedSegmentIndex==0) {
        return self.dataSourceArray.count;
    }else{
        return self.downLoadedArray.count;

    }
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    KMZCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"kmzcell" forIndexPath:indexPath];
    cell.backgroundColor=[UIColor whiteColor];
    int i=indexPath.row;
    
    
    if (self.segement.selectedSegmentIndex==0) {
        NSString *cellInfo=[self.dataSourceArray objectAtIndex:i];
        NSArray *infoArrayBySeparate=[cellInfo componentsSeparatedByString:@","];
        
        if ([infoArrayBySeparate count]>1) {
            if ([infoArrayBySeparate objectAtIndex:1]!=nil) {
                cell.nameLabel.text=[infoArrayBySeparate objectAtIndex:1];
                
            }
            if ([infoArrayBySeparate objectAtIndex:2]!=nil) {
                cell.authorLabel.text=[infoArrayBySeparate objectAtIndex:2];
                
            }
            if ([infoArrayBySeparate objectAtIndex:3]!=nil) {
                cell.startTimeLabel.text=[infoArrayBySeparate objectAtIndex:3];
                
            }
            if ([infoArrayBySeparate objectAtIndex:4]!=nil) {
                cell.endTimeLabel.text=[infoArrayBySeparate objectAtIndex:4];
                
            }
            if ([infoArrayBySeparate objectAtIndex:5]!=nil) {
                cell.sizeLabel.text=[infoArrayBySeparate objectAtIndex:5];
                
            }
            
        }
        //管理员

    }else{
        NSMutableArray *cellInfoArray=[self.downLoadedArray objectAtIndex:i];
        cell.nameLabel.text=[cellInfoArray objectAtIndex:0];
        cell.authorLabel.text=[cellInfoArray objectAtIndex:1];
        cell.startTimeLabel.text=[cellInfoArray objectAtIndex:2];
        cell.endTimeLabel.text=[cellInfoArray objectAtIndex:3];
        
        NSString *dirName=[[self.downLoadedArray objectAtIndex:indexPath.row]lastObject];
        NSString *dirPath=[self.listPath stringByAppendingPathComponent:dirName];
        NSString *imagePath=[dirPath stringByAppendingPathComponent:@"ThumBnail.png"];
        cell.imageView.image=[UIImage imageWithContentsOfFile:imagePath];

        
        
    }
    return cell;

}

#pragma mark -UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.segement.selectedSegmentIndex==0) {
        NSString *cellInfo=[self.dataSourceArray objectAtIndex:indexPath.row];
        NSArray *infoArrayBySeparate=[cellInfo componentsSeparatedByString:@","];
        if ([infoArrayBySeparate count]>1) {
            [self.downLoadArray addObject:[infoArrayBySeparate objectAtIndex:0]];
        }

    }else{
//        NSLog(@"kml:%@",[self.downLoadedArray objectAtIndex:indexPath.row]lastObject)
        NSString *dirName=[[self.downLoadedArray objectAtIndex:indexPath.row]lastObject];
        NSString *dirPath=[self.listPath stringByAppendingPathComponent:dirName];
        NSString *kmlPath=[dirPath stringByAppendingPathComponent:@"RouteRecord.kml"];
        [self.willShowKMLArray addObject:kmlPath];
    }
    
}


#pragma mark -UIPickerViewDataSource
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.searchTypeList.count;
}
-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 50;
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    self.serachIden=row;
    self.searchTypeStr=[self.searchTypeList objectAtIndex:row];
    
    NSLog(@"current:%d",self.serachIden);
    if (row==4) {
        [self performSegueWithIdentifier:@"ShowRectSearch" sender:nil];

    }
    
}
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [self.searchTypeList objectAtIndex:row];
}


#pragma mark - Notification
-(void)receiveNotification{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationHandel:) name:@"areaNotification" object:nil];
}
-(void)notificationHandel:(NSNotification *)notification{
    NSArray *areaArray=[notification object];
    NSLog(@"%@",[areaArray objectAtIndex:1]);
    
    //http://159.226.15.215:8081/samples/kmz/selectbyarea.jsp?latitude=39.977772-40.062283&longitude=116.329018-116.341278
    
    NSMutableArray *buffer=[areaArray mutableCopy];
    float i=[[buffer objectAtIndex:0]floatValue];
    float j=[[buffer objectAtIndex:1]floatValue];
    
    float m=[[buffer objectAtIndex:2]floatValue];
    float n=[[buffer objectAtIndex:3]floatValue];
    
    if (i>j) {
        [buffer exchangeObjectAtIndex:0 withObjectAtIndex:1];
    }
    if (m>n) {
        [buffer exchangeObjectAtIndex:2 withObjectAtIndex:3];
    }
    
    
    NSString *urlString=[NSString stringWithFormat:@"http://159.226.15.215:8081/samples/kmz/selectbyarea.jsp?latitude=%@-%@&longitude=%@-%@",[buffer objectAtIndex:0],[buffer objectAtIndex:1],[buffer objectAtIndex:2],[buffer lastObject]];
    NSLog(@"%@",urlString);
    NSError *error;
    NSString *encodedURLString=(NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)urlString, NULL, NULL, kCFStringEncodingUTF8));
    NSString *results=[NSString stringWithContentsOfURL:[NSURL URLWithString:encodedURLString] encoding:NSUTF8StringEncoding error:&error];
    self.dataSourceArray=[[results componentsSeparatedByString:@";"]mutableCopy];

    
    [self.collectionView reloadData];
}

#pragma maek -Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"ShowKMLViewer"]) {
        kmViewController *kv=segue.destinationViewController;
        kv.kmlData=self.willShowKMLArray;
    }
}


@end
