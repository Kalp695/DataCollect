//
//  FileColViewController.m
//  DataCollect
//
//  Created by liucc on 13-12-24.
//  Copyright (c) 2013年 liucc. All rights reserved.
//

#import "FileColViewController.h"
#import "CustomCollectionCell.h"
#import "VssbViewController.h"
#import "CustomNavigationController.h"
#import "ASIFormDataRequest.h"
#import "Util.h"
#import "AibViewController.h"
#import "SearchView.h"
#import "hpple/TFHpple.h"


#import "CoreDataStore.h"
#import "NSManagedObject+InnerBand.h"
#import "Track.h"
#import "TrackMapViewController.h"

#import "OfflineViewController.h"
#import <MAMapKit/MAMapKit.h>

#define kCellID @"collectionCell"


@interface FileColViewController () <CustomNavgationDelegate>

@property(nonatomic,strong)NSMutableArray *containerArray;
//用于存放轨迹的array以及用于缓存的bufferarray
@property(nonatomic,strong)NSMutableArray *trackArray;
@property(nonatomic,strong)NSMutableArray *bufferArray;

@property(nonatomic,strong)NSMutableArray *tracks;

//存放搜索返回的结果
@property(nonatomic,strong)NSMutableArray *searchResults;

//搜索按钮
@property(nonatomic,strong)UIButton *searchBtn;
//离线地图按钮
@property(nonatomic,strong)UIButton *offlineBtn;
@property(nonatomic,strong)NSString *bufferPath;

@property(nonatomic,assign)BOOL isEditState;
@property(nonatomic,strong)NSMutableArray *bufferCellArray;
@property(nonatomic,strong)NSMutableArray *delIndexPaths;


@property(nonatomic,strong)ASIFormDataRequest *request;


@property(nonatomic,strong)NSMutableDictionary *uploadFlagDic;
@property(nonatomic,assign)BOOL ifExistUploadFlag;
@end

@implementation FileColViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)loadView{
    [super loadView];
//    self.title=@"FileList";
    self.isEditState=NO;
    self.bufferCellArray = [@[] mutableCopy];
    self.delIndexPaths=[@[] mutableCopy];

    //设置collectionView 中cell的内边距
    UIEdgeInsets inset=UIEdgeInsetsMake(10, 10, 0, 10);
    self.collectionView .contentInset=inset;
    //允许多选cell
    self.collectionView.allowsMultipleSelection=YES;
    
    self.segmentalBtn.selectedSegmentIndex=0;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initEditButton];
    
    //TODO
    /*
    在应用第一次启动时，将在沙盒中穿件目录以保存数据表。
     以后若干次启动时，首先读取沙盒中的数据表目录以获得本collectionview的数据源，
     并根据数据源来配置collectionView；
     */
    [self readDir:self.listPath];
    
    //判断是否存在上传标识plist
    if (!self.ifExistUploadFlag) {
        //新建一个uploadFlagPlist
        NSString *fileName=@"UploadFlag.plist";
        NSString *filePath=[self.listPath stringByAppendingPathComponent:fileName];
        [self.uploadFlagDic writeToFile:filePath atomically:YES];
    }else{
        NSString *fileName=@"UploadFlag.plist";
        NSString *filePath=[self.listPath stringByAppendingPathComponent:fileName];

        self.uploadFlagDic=[[NSMutableDictionary alloc]initWithContentsOfFile:filePath];
    }
    [self addSearchBtnToNav];
}

-(void)initEditButton{
    UIBarButtonItem *rightBarButtonItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editItemClicked)];
    self.navigationItem.rightBarButtonItem=rightBarButtonItem;
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    //searchBtn 和offlineBtn的隐藏
    if (self.segmentalBtn.selectedSegmentIndex==1) {
        self.searchBtn.hidden=NO;
        self.offlineBtn.hidden=NO;
    }

    [self hideToolBar];
    for (int i=0;  i<self.collectionView.indexPathsForSelectedItems.count; i++) {
        [self.collectionView deselectItemAtIndexPath:[self.collectionView.indexPathsForSelectedItems objectAtIndex:i] animated:YES];
    }
    //从数据库中读取轨迹
    NSError *error;
    
    
    NSArray *bufferTracks=[[CoreDataStore mainStore]allForEntity:@"Track" orderBy:@"created" ascending:NO error:&error];
    for (int i=self.tracks.count; i>1; i--) {
        [self.tracks removeLastObject];
    }

    [self.tracks addObjectsFromArray:bufferTracks];
    
    if (error) {
        NSLog(@"%@",error);
    }
    
    [self.collectionView reloadData];

}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.searchBtn.hidden=YES;
    self.offlineBtn.hidden=YES;
}

#pragma mark -Accessor

-(NSMutableArray *)containerArray{
    if (!_containerArray) {
        _containerArray=[[NSMutableArray alloc]init];
        
        [_containerArray addObject:[NSNumber numberWithInt:0]];
    }
    return _containerArray;
}
-(NSMutableArray *)bufferArray{
    if (!_bufferArray) {
        _bufferArray=[[NSMutableArray alloc]init];
    }
    return _bufferArray;
}
-(NSMutableArray *)tracks{
    if (!_tracks) {
        _tracks=[[NSMutableArray alloc]init];
        [_tracks addObject:[NSNumber numberWithInt:0]];
    }
    return _tracks;
}
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
        switch (self.gridType) {
            case GridTypeForPlant:
                _listPath=[self.documnetPath stringByAppendingPathComponent:@"plantList"];
                break;
            case GridTypeForAnimal:
                _listPath=[self.documnetPath stringByAppendingPathComponent:@"animalList"];
                break;
            case GridTypeForTrack:
                _listPath=[self.documnetPath stringByAppendingString:@"trakList"];
            default:
                break;
        }
    }
    return _listPath ;
}
-(NSMutableDictionary *)uploadFlagDic{
    if (!_uploadFlagDic) {
        _uploadFlagDic=[[NSMutableDictionary alloc]init];
    }
    return _uploadFlagDic;
}

-(void)readDir:(NSString *)listPath{
    //    NSArray *dirs=[self.fileManager subpathsAtPath:self.documnetPath];
    NSArray *dirs= [self.fileManager contentsOfDirectoryAtPath:listPath error:nil];
    NSMutableArray *temDirs=[NSMutableArray arrayWithArray:dirs];
    //    contentsDirectory = [self.fm contentsOfDirectoryAtPath: currentPath error: nil];
    if ([temDirs indexOfObject:@".DS_Store"]!=NSNotFound) {
        [temDirs removeObject:@".DS_Store"];
    }
    if ([temDirs containsObject:@"UploadFlag.plist"]) {
        [temDirs removeObject:@"UploadFlag.plist"];
        self.ifExistUploadFlag=YES;
    }else{
        self.ifExistUploadFlag=NO;
    }
    for (int i=self.containerArray.count; i>1; i--) {
        [self.containerArray removeLastObject];
    }
    for (NSString *dateString in temDirs) {
        [self.containerArray addObject:dateString];
    }
}



#pragma mark -CustomNav Delegate

-(void)trashItemClicked{
    for (NSString *delDateString in self.bufferCellArray) {
        [self.containerArray removeObject:delDateString];
        NSString *dirString=[self.listPath stringByAppendingPathComponent:delDateString];
        [self.fileManager removeItemAtPath:dirString error:nil];
    }
    [self.collectionView deleteItemsAtIndexPaths:self.delIndexPaths];
}
-(void)uploadItemClicked{
    for (NSString *uploadString in self.bufferCellArray) {
        NSString *dirString=[self.listPath stringByAppendingPathComponent:uploadString];
        NSString *zipName=[NSString stringWithFormat:@"t_siyfi_vssb&vtp_%@.zip",uploadString];
        NSString *zipPath=[dirString stringByAppendingPathComponent:zipName];
        
//        [self.request cancel];
//        [self setRequest:[ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"http://159.226.15.215:8081/samples/apk/Upload.jsp"]]];
        
        ASIFormDataRequest *requestEst=[ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"http://159.226.15.215:8081/samples/apk/Upload.jsp"]];
        
        [requestEst setShouldContinueWhenAppEntersBackground:YES];
        [requestEst setDelegate:self];
        [requestEst setFile:zipPath forKey:uploadString];
        [requestEst startAsynchronous];
    }
    //修改uploadFlag中对应的BOOL value;
    for (NSString *titleString in self.bufferCellArray) {
        [self.uploadFlagDic setValue:[NSNumber numberWithBool:YES] forKey:titleString];
    }
    NSString *fileName=@"UploadFlag.plist";
    NSString *filePath=[self.listPath stringByAppendingPathComponent:fileName];
    [self.uploadFlagDic writeToFile:filePath atomically:YES];
    
//    [self.collectionView reloadData];
    for (NSIndexPath *path in self.delIndexPaths) {
        CustomCollectionCell *cell=(CustomCollectionCell *)[self.collectionView cellForItemAtIndexPath:path];
        [cell.uploadFlag setHidden:NO];
    }
}
-(void)editItemClicked{
    self.isEditState=YES;
    [self showToolBar];
    UIBarButtonItem *rightBarButtonItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneItemClicked)];
    self.navigationItem.rightBarButtonItem=rightBarButtonItem;
    NSArray *cellAarray=[self.collectionView visibleCells];
    NSMutableArray *mutablCellArray=[cellAarray mutableCopy];
    for (CustomCollectionCell *cell in mutablCellArray) {
        NSIndexPath *indexPath=[self.collectionView indexPathForCell:cell];
        if (indexPath.row!=0) {
            CGFloat rotation = 0.03;
            CABasicAnimation *shake = [CABasicAnimation animationWithKeyPath:@"transform"];
            shake.duration = 0.13;
            shake.autoreverses = YES;
            shake.repeatCount  = MAXFLOAT;
            shake.removedOnCompletion = NO;
            shake.fromValue = [NSValue valueWithCATransform3D:CATransform3DRotate(cell.layer.transform,-rotation, 0.0 ,0.0 ,1.0)];
            shake.toValue   = [NSValue valueWithCATransform3D:CATransform3DRotate(cell.layer.transform, rotation, 0.0 ,0.0 ,1.0)];
            [cell.layer addAnimation:shake forKey:@"shakeAnimation"];
            
        }
    }
    
}
-(void)doneItemClicked{
    self.isEditState=NO;
    [self hideToolBar];
    UIBarButtonItem *rightBarButtonItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editItemClicked)];
    self.navigationItem.rightBarButtonItem=rightBarButtonItem;
    NSArray *cellArray=[self.collectionView visibleCells];
    for (CustomCollectionCell *cell in cellArray ) {
        [cell.layer removeAnimationForKey:@"shakeAnimation"];
    }
    //去掉反选的选中状态
//    for (int i=0;  i<self.collectionView.indexPathsForSelectedItems.count; i++) {
//        [self.collectionView deselectItemAtIndexPath:[self.collectionView.indexPathsForSelectedItems objectAtIndex:i] animated:YES];
//    }
}

#pragma mark -Private Method

-(void)hideToolBar{
    CustomNavigationController *navController=(CustomNavigationController *)self.navigationController;
    navController.cDelegate=self;
    navController.toolBar.hidden=YES;
    self.segmentalBtn.hidden=NO;
    //hide the picker
    if (navController.picker) {
        navController.picker.hidden=YES;
    }
}
-(void)showToolBar{
    self.segmentalBtn.hidden=YES;
    CustomNavigationController *navController=(CustomNavigationController *)self.navigationController;
    navController.cDelegate=self;
    navController.toolBar.hidden=NO;
}

- (IBAction)switchBySeg:(id)sender {
    [self switchBtnVisiblity];
    if (self.segmentalBtn.selectedSegmentIndex==0) {
        self.gridType=[Util getCurrentUserInfo].userRole;
        switch (self.gridType) {
            case GridTypeForPlant:
                self.listPath=[self.documnetPath stringByAppendingPathComponent:@"plantList"];
                break;
            case GridTypeForAnimal:
                self.listPath=[self.documnetPath stringByAppendingPathComponent:@"animalList"];
                break;
            default:
                break;
        }
        [self readDir:self.listPath];
        [self.collectionView reloadData];
        
    }else{
        self.gridType=GridTypeForTrack;
//        self.listPath=[self.documnetPath stringByAppendingPathComponent:@"trackList"];
//        [self readDir:self.listPath];
        [self.collectionView reloadData];
        //显示搜索地图按钮 addSearchBtnToNav
        
    }
}

-(void)addSearchBtnToNav{
    CustomNavigationController *navCon=(CustomNavigationController *)self.navigationController;
    self.searchBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    [self.searchBtn setFrame:CGRectMake(250, 0, 100, 44)];
    [self.searchBtn setTitle:@"搜索" forState:UIControlStateNormal ];
    [self.navigationController.navigationBar addSubview:self.searchBtn];
    self.searchBtn.hidden=YES;
    [self.searchBtn addTarget:self action:@selector(searchKMZ) forControlEvents:UIControlEventTouchUpInside];
    navCon.searchBtn=self.searchBtn;
    [self addOfflineMapBtn];

}

-(void)addOfflineMapBtn{
    self.offlineBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    [self.offlineBtn setFrame:CGRectMake(350, 0, 100, 44)];
    [self.offlineBtn setTitle:@"离线地图" forState:UIControlStateNormal ];
    [self.navigationController.navigationBar addSubview:self.offlineBtn];
    self.offlineBtn.hidden=YES;
    [self.offlineBtn addTarget:self action:@selector(switchToOffline) forControlEvents:UIControlEventTouchUpInside];
}
-(void)searchKMZ{
    /*TODO List
     segue 跳转至搜索页面*/
    [self performSegueWithIdentifier:@"ShowSearchType" sender:nil];
}
-(void)switchToOffline{
    [self performSegueWithIdentifier:@"ShowOfflineMap" sender:nil];
}

-(void)switchBtnVisiblity{
    if (self.segmentalBtn.selectedSegmentIndex==0) {
        self.searchBtn.hidden=YES;
        self.offlineBtn.hidden=YES;
    }else if(self.segmentalBtn.selectedSegmentIndex==1){
        self.searchBtn.hidden=NO;
        self.offlineBtn.hidden=NO;

    }
//    if (self.searchBtn.hidden==YES) {
//        self.searchBtn.hidden=NO;
//        self.offlineBtn.hidden=NO;
//    }else{
//        self.searchBtn.hidden=YES;
//        self.offlineBtn.hidden=YES;
//    }
}


#pragma mark-UICollectionViewDelegate&DataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (self.gridType == GridTypeForSearch) {
        return self.searchResults.count;
    }
    
    
    if (self.gridType==GridTypeForTrack) {
        return self.tracks.count;
    }else{
        return self.containerArray.count;}
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CustomCollectionCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kCellID forIndexPath:indexPath];
    cell.backgroundColor=[UIColor whiteColor];
    //搜索tracks返回结果后的显示内容
    if (self.gridType==GridTypeForSearch) {
        //cell.image=截图
        int i=indexPath.row;
        NSString *cellInfo=[self.searchResults objectAtIndex:i];
        NSArray *infoArrayBySeparate=[cellInfo componentsSeparatedByString:@","];
//        NSString *name=[infoArrayBySeparate objectAtIndex:1];
//        cell.label.text=name;
        NSLog(@"info:%@",[infoArrayBySeparate objectAtIndex:0]);
//        NSLog(@"the count %d",infoArrayBySeparate.count);
        
        return cell;
        
    }
    
    //正常现实
    if (indexPath.row==0) {
        cell.image.image=[UIImage imageNamed:@"add.png"];
        cell.label.text=[NSString stringWithFormat:@"{%ld}",(long)indexPath.row];
        cell.uploadFlag.hidden=YES;
    }else{
        
        
        if (self.gridType==GridTypeForTrack) {
            int i =indexPath.row;
            Track *track = [self.tracks objectAtIndex:i];
            
            NSDateFormatter *formatter = [NSDateFormatter new];
            formatter.dateFormat = @"yyyy-MM-dd hh:mm:ss";
            NSString *text = [formatter stringFromDate:track.created];
            
            cell.label.text = text;

        }else{
        
            NSString *cellList=[self.listPath stringByAppendingPathComponent:[self.containerArray objectAtIndex:indexPath.row]];
            NSString *screenShotPath=[cellList stringByAppendingPathComponent:@"screenshot.png"];

        
        
        if ([self.fileManager fileExistsAtPath:screenShotPath]) {
            cell.image.image=[UIImage imageWithContentsOfFile:screenShotPath];
        }else{
            cell.image.image=[UIImage imageNamed:@"logo.png"];
        }
            
        NSString *prefix;
            switch (self.gridType) {
                case GridTypeForPlant:
                    prefix=@"植物调查表";
                    break;
                case GridTypeForAnimal:
                    prefix=@"动物调查表";
                    break;
                    
                default:
                    break;
            }
            NSString *suffix=[self.containerArray objectAtIndex:indexPath.row];
//        cell.label.text=[self.containerArray objectAtIndex:indexPath.row];
            cell.label.text=[NSString stringWithFormat:@"%@_%@_%@",prefix,[Util getCurrentUserInfo].userName,suffix];
        //获取plist文件中的是否上传标示，若为yes,则cell.uploadimage.hidden=no;
        if ([self.uploadFlagDic valueForKey:[self.containerArray objectAtIndex:indexPath.row]]) {
            cell.uploadFlag.hidden=NO;
        }else{
            cell.uploadFlag.hidden=YES;
        }
        }
    }
    return cell ;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.isEditState) {
        NSString *dateString=[self.containerArray objectAtIndex:indexPath.row];
        [self.bufferCellArray addObject:dateString];
        [self.delIndexPaths addObject:indexPath];
    }else {
        if (indexPath.row==0) {
            if (self.gridType==GridTypeForTrack) {
                [self performSegueWithIdentifier:@"PushMapFromAdd" sender:[self.containerArray objectAtIndex:indexPath.row]];
            }else{
            NSDate *date=[NSDate date];
            NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
            [dateFormatter setDateFormat:@"yyyy_MM_dd_HH_mm_ss"];
            NSString *dateString=[dateFormatter stringFromDate:date];
            [self.containerArray addObject:dateString];
            [self.collectionView reloadData];
                [self createDirByDate];}
        }else{
            switch (self.gridType) {
                case GridTypeForPlant:
                    [self performSegueWithIdentifier:@"ShowVssbFromFile" sender:[self.containerArray objectAtIndex:indexPath.row]];
                    break;
                case GridTypeForAnimal:
                    [self performSegueWithIdentifier:@"ShowAibFromFile" sender:[self.containerArray objectAtIndex:indexPath.row]];
                    break;
                case GridTypeForTrack:
                    [self performSegueWithIdentifier:@"PushMapFromShow" sender:indexPath];
                    break;

                default:
                    break;
            }
            
        }
    }
}
-(void)createDirByDate{
    NSString *dateString=[self.containerArray lastObject];
    NSString *dateDirPath=[self.listPath stringByAppendingPathComponent:dateString];
    [self.fileManager createDirectoryAtPath:dateDirPath withIntermediateDirectories:YES attributes:nil error:nil];
}


#pragma mark -Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if (self.gridType==GridTypeForPlant) {
        VssbViewController *vssb=segue.destinationViewController;
        NSString *title=(NSString *)sender;
        vssb.dirTitle=title;
        if ([self.uploadFlagDic valueForKey:title]) {
            vssb.isUploaded=YES;
        }else{
            vssb.isUploaded=NO;
        }
    }else if(self.gridType==GridTypeForAnimal){
        AibViewController *aib=segue.destinationViewController;
        NSString *title=(NSString *)sender;
        aib.dirTitle=title;
        aib.isUploaded=(BOOL)[self.uploadFlagDic valueForKey:title];
    }else if(self.gridType==GridTypeForTrack){
        if ([segue.identifier isEqualToString:@"PushMapFromShow"]) {
            
            NSIndexPath *indexPath = (NSIndexPath *)sender;
//            int i =indexPath.row+1;
            Track *track = [self.tracks objectAtIndex:indexPath.row];
            
            TrackMapViewController *viewController = (TrackMapViewController *)segue.destinationViewController;
            viewController.track = track;
        }
    }

    if ([segue.identifier isEqualToString:@"ShowOfflineMap"]) {
        OfflineViewController *offVC=segue.destinationViewController;
        offVC.mapView=[[MAMapView alloc]initWithFrame:self.view.bounds];

    }
    
    
}



@end
