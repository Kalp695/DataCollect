//
//  AibViewController.m
//  DataCollect
//
//  Created by liucc on 1/21/14.
//  Copyright (c) 2014 liucc. All rights reserved.
//

#import "AibViewController.h"
#import "GetTemplateInfo.h"
#import "TemplateInfo.h"
#import "AidViewController.h"

@interface AibViewController ()<UITextFieldDelegate>
@property(nonatomic,assign)BOOL ifExistFile;
@property(nonatomic,strong)NSString *path;
@property(nonatomic,strong)NSMutableArray *templateArray;
@property(nonatomic,strong)NSMutableArray *textFieldArray;

@end

@implementation AibViewController

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
    [self initWidget];
    if (self.ifExistFile) {
        [self getDataFromPlist];
    }
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [self saveDataToPlist];
}

#pragma mark-Accessor
-(NSString *)path{
    if (!_path) {
        NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *listPath=[[paths firstObject]stringByAppendingPathComponent:@"animalList"];
        _path=[listPath stringByAppendingPathComponent:self.dirTitle];
    }
    return _path;
}
-(BOOL)ifExistFile{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSString *fileName=@"AibData.plist";
    NSString *filePath=[self.path stringByAppendingPathComponent:fileName];
    return [fileManager fileExistsAtPath:filePath];
}
-(NSMutableArray *)templateArray{
    if (!_templateArray) {
        GetTemplateInfo *getTe=[GetTemplateInfo templateAccess];
        _templateArray=[getTe getAniTemInfoFromTp];
    }
    return _templateArray;
}
-(NSMutableArray *)textFieldArray{
    if (!_textFieldArray) {
        _textFieldArray=[@[]mutableCopy];
    }
    return _textFieldArray;
}

-(void)initWidget{
    NSMutableArray *displayArray=[@[]mutableCopy];
    for (TemplateInfo *data in self.templateArray) {
        if (data.ifDisplay) {
            [displayArray addObject:data];
        }
    }
    for (int i=0; i<displayArray.count; i++) {
        float x=self.view.center.x-150;
        float height=21.0;
        float tap=40.0;
        float y=130+i*(height+tap);
        UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(x, y, 85, height)];
        TemplateInfo *data=[displayArray objectAtIndex:i];
        label.text=data.name;
        [self.view addSubview:label];
    }
    for (int i=0; i<displayArray.count; i++) {
        float x=self.view.center.x-65;
        float height=21.0;
        float tap=40.0;
        float y=126+i*(height+tap);
        UITextField *textfield=[[UITextField alloc]initWithFrame:CGRectMake(x, y, 150, 30)];
        textfield.borderStyle=UITextBorderStyleRoundedRect;
//        UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(x, y, 85, height)];
        TemplateInfo *data=[displayArray objectAtIndex:i];
//        label.text=data.name;
        textfield.tag=i;
        textfield.delegate=self;
        [self.textFieldArray addObject:textfield];
        [self.view addSubview:textfield];
    }
}

-(void)getDataFromPlist{
    NSString *fileName=@"AibData.plist";
    NSString *filePath=[self.path stringByAppendingPathComponent:fileName];
    NSDictionary *dic=[[NSDictionary alloc]initWithContentsOfFile:filePath];
    for (UITextField *textField in self.textFieldArray) {
        textField.text=[dic objectForKey:[NSString stringWithFormat:@"%d",textField.tag]];
    }
}
-(void)saveDataToPlist{
    NSMutableDictionary *rootObj=[NSMutableDictionary dictionaryWithCapacity:self.textFieldArray.count];
    for (int i=0; i<self.textFieldArray.count; i++) {
        UITextField *flagTextField=[self.textFieldArray objectAtIndex:i];
        [rootObj setObject:flagTextField.text forKey:[NSString stringWithFormat:@"%d",flagTextField.tag]];
    }
    NSString *fileName=@"AibData.plist";
    NSString *filePath=[self.path stringByAppendingPathComponent:fileName];
    [rootObj writeToFile:filePath atomically:YES];
 }


#pragma mark -TextFieldDelegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return !self.isUploaded;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


- (IBAction)nextClicked:(id)sender {
    [self performSegueWithIdentifier:@"ShowAidFromAib" sender:self.dirTitle];

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    AidViewController *aid=segue.destinationViewController;
    NSString *title=(NSString *)sender;
    aid.dirTitle=title;
}



@end
