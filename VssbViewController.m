//
//  VssbViewController.m
//  DataCollect
//
//  Created by liucc on 14-1-2.
//  Copyright (c) 2014年 liucc. All rights reserved.
//



/*
 初始化时获取两个信息~~一个时间戳，以此来寻找Docu目录中的文件夹，由cell点击时获得
 根据以上获得的时间戳扫描文件夹，若为空则在退出的时候保存，若不为空则获取文件内容并作为数据源
 数据源为两个：一个基本表的plist（xml），一个信息表的xml
 */

#import "VssbViewController.h"
#import "VtpViewController.h"
#import "CustomNavigationController.h"
#import <DDXML.h>
#import "Util.h"

@interface VssbViewController () <UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property(nonatomic,strong)NSString *path;
@property(nonatomic,strong)CLLocationManager *locManager;
@property(nonatomic,assign)CLLocationCoordinate2D loc;

@property(nonatomic,strong)UIImagePickerController *imagePicker;

@end

@implementation VssbViewController

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
    self.view.backgroundColor=[UIColor grayColor];
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSArray *dirs=[fileManager subpathsOfDirectoryAtPath:self.path error:nil];
    //生成textField的数据录入界面
    if (self.ifExistFile) {
        //如果有文件（xml）,则读取文件并将其中的内容作为数据加载到textField中
        [self getDataFromPlist];
    }else{
        //如果没有，则将textField的内容全部置为0
//        NSLog(@"nothing");
    }
//    NSLog(@"the contentis %@",self.dirTitle);
    
    
    CustomNavigationController *navController=(CustomNavigationController *)self.navigationController;
    navController.toolBar.hidden=YES;
    
    NSLog(@"%f",self.loc.latitude);

}

-(CLLocationManager *)locManager{
    if (!_locManager) {
        _locManager=[[CLLocationManager alloc]init];
        _locManager.delegate=self;
        [_locManager setDesiredAccuracy:kCLLocationAccuracyBest];
    }
    return _locManager;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self.locManager startUpdatingLocation];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
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
    NSArray *dirs=[fileManager subpathsOfDirectoryAtPath:self.path error:nil];
    NSMutableArray *temDirs=[NSMutableArray arrayWithArray:dirs];
    //    contentsDirectory = [self.fm contentsOfDirectoryAtPath: currentPath error: nil];
    if ([temDirs indexOfObject:@".DS_Store"]!=NSNotFound) {
        [temDirs removeObject:@".DS_Store"];
    }
    if ([temDirs count]!=0) {
        return YES;
    }else{
        return NO;
    }
}
- (IBAction)saveClicked:(id)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self saveDataToPlist];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"ShowVtpFromVsb" sender:self.dirTitle];

        });
    });
    
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    VtpViewController *vtp=segue.destinationViewController;
    NSString *title=(NSString *)sender;
    vtp.dirTitle=title;
    vtp.isUploaded=self.isUploaded;

}
-(void)getDataFromPlist{
    NSString *fileName=@"VssbData.plist";
    NSString *filePath=[self.path stringByAppendingPathComponent:fileName];
    NSDictionary *dic=[[NSDictionary alloc]initWithContentsOfFile:filePath];
    for (UITextField *textFiled in self.textFieldArray) {
        textFiled.text=[dic objectForKey:[NSString stringWithFormat:@"%d",textFiled.tag]];
        textFiled.delegate=self;
    }
}
-(void)saveDataToPlist{
    //保存当前数据到沙河中的文件
    NSMutableDictionary *rootObj=[NSMutableDictionary dictionaryWithCapacity:self.textFieldArray.count];
    for (int i=0; i<self.textFieldArray.count; i++) {
        UITextField *flagTextField=[self.textFieldArray objectAtIndex:i];
        [rootObj setObject:flagTextField.text forKey:[NSString stringWithFormat:@"%d",flagTextField.tag]];
    }
    NSString *fileName=@"VssbData.plist";
    NSString *filePath=[self.path stringByAppendingPathComponent:fileName];
    [rootObj writeToFile:filePath atomically:YES];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [self saveDataToPlist];
    //写入xml
    [self writeSelfDataToXml];
}
-(void)writeSelfDataToXml{
    NSString *fileName=[NSString stringWithFormat:@"t_siyfi_vssb_%@_%@.xml",[Util getCurrentUserInfo].userName, self.dirTitle];
    DDXMLElement *ele_root=[DDXMLElement elementWithName:@"list"];
    DDXMLElement *ele_node=[DDXMLElement elementWithName:@"node"];
    for (int i=0; i<self.textFieldArray.count; i++) {
        UITextField *flagTextField=[self.textFieldArray objectAtIndex:i];
        [ele_node addAttribute:[DDXMLNode attributeWithName:[NSString stringWithFormat:@"%d",i] stringValue:flagTextField.text]];
    }
    [ele_root addChild:ele_node];
    NSString *xmlString =[ele_root XMLString];
    NSMutableString *mutableXmlString=[xmlString mutableCopy];
    NSString *path=[self.path stringByAppendingPathComponent:fileName];
    [mutableXmlString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
}



#pragma mark -UITextfiledDelegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (self.isUploaded) {
        return NO;
    }else{
        return YES;
    }
}


#pragma mark -CLLocationManagerDelegate
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocationCoordinate2D loc=[[locations lastObject]coordinate];
    self.loc=loc;
}


- (IBAction)switchAction:(id)sender {
    self.switchBtn=(UISwitch *)sender;
    UITextField *lotextField=(UITextField *)[self.view viewWithTag:6];
    UITextField *latextField=(UITextField *)[self.view viewWithTag:7];
    if ([self.switchBtn isOn]) {
        lotextField.text=[NSString stringWithFormat:@"%f",self.loc.longitude];
        latextField.text=[NSString stringWithFormat:@"%f",self.loc.latitude];
    }
    
}
- (IBAction)getNearPic:(id)sender {
    self.imagePicker=[[UIImagePickerController alloc]init];
    self.imagePicker.delegate=self;
    self.imagePicker.sourceType=UIImagePickerControllerSourceTypeCamera;
    self.imagePicker.modalTransitionStyle =UIModalTransitionStyleCoverVertical;
    self.imagePicker.allowsEditing=NO;
    [self presentViewController:self.imagePicker animated:YES completion:^{
        nil;
    }];
}
- (IBAction)getFarPic:(id)sender {
    self.imagePicker=[[UIImagePickerController alloc]init];
    self.imagePicker.delegate=self;
    self.imagePicker.sourceType=UIImagePickerControllerSourceTypeCamera;
    self.imagePicker.modalTransitionStyle =UIModalTransitionStyleCoverVertical;
    self.imagePicker.allowsEditing=NO;
    [self presentViewController:self.imagePicker animated:YES completion:^{
        nil;
    }];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image;
    image=[info objectForKey:UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:^{
        nil;
    }];
    UIImageView *imgView=[[UIImageView alloc]initWithFrame:self.nearPicView.bounds];
    [imgView setImage:image];
    [self.nearPicView addSubview:imgView];
    //将照片和视频储存到文件中，照片的文件名是时间戳 video.name=self.timestamp;
//    NSString *imgPath=[self.imgDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",self.timeStamp]];
//    [UIImagePNGRepresentation(image) writeToFile:imgPath atomically:YES];
    

}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}


@end
