//
//  LoginViewController.m
//  DataCollect
//
//  Created by liucc on 1/14/14.
//  Copyright (c) 2014 liucc. All rights reserved.
//

#import "LoginViewController.h"
#import "UserEntity.h"
#import "Util.h"
#import "FileColViewController.h"
#import "CustomNavigationController.h"
#import "NSString+EncodingUTF8Additions.h"
#import "Reachability.h"

#import "SearchView.h"

@interface LoginViewController ()

@property(nonatomic,assign)BOOL showRegister;
@property(nonatomic,strong)UIWebView *registerWeb;

@end

@implementation LoginViewController

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
    [self checkReachability];
    UserEntity *user=[Util getCurrentUserInfo];
    user.isLogin=YES;
    user.userName=self.userNameField.text;
	// Do any additional setup after loading the view.
    
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [Util getCurrentUserInfo].userName=self.userNameField.text;
    [super viewWillDisappear:YES];
    if ([[Util getCurrentUserInfo].userName isEqualToString:@"plant"]) {
        [Util getCurrentUserInfo].userRole=UserRoleForPlant;
    }
    if ([[Util getCurrentUserInfo].userName isEqualToString:@"animal"]) {
        [Util getCurrentUserInfo].userRole=UserRoleForAnimal;
    }
}

- (void)didReceiveMemoryWarning
{

    // Dispose of any resources that can be recreated.
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    [Util getCurrentUserInfo].userName=self.userNameField.text;
    [super viewWillDisappear:YES];
    if ([[Util getCurrentUserInfo].userName isEqualToString:@"plant"]) {
        [Util getCurrentUserInfo].userRole=UserRoleForPlant;
    }
    if ([[Util getCurrentUserInfo].userName isEqualToString:@"animal"]) {
        [Util getCurrentUserInfo].userRole=UserRoleForAnimal;
    }
    
    CustomNavigationController *cnc=segue.destinationViewController;
    FileColViewController *fcv=(FileColViewController *)cnc.topViewController;
    fcv.gridType=[Util getCurrentUserInfo].userRole;
}
-(void)judgeLoginInfo{
    NSString *loginString=[NSString stringWithFormat:@"http://159.226.15.218:50080/sjyfi/logincheckformobile.jsp?account=%@&password=%@",self.userNameField.text,self.passWordField.text];
    NSURL *loginUrl=[NSURL URLWithString:loginString];
    
    //读取GBK编码的文件
    NSStringEncoding gbkEdcoding=CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *result=[NSString stringWithContentsOfURL:loginUrl encoding:gbkEdcoding error:nil];

    
//    NSString *result=[NSString stringWithContentsOfURL:loginUrl encoding:NSUTF8StringEncoding error:nil];
    NSRange range=[result rangeOfString:@"No such ACCOUNT"];
    NSRange range1=[result rangeOfString:@"Wrong PSW"];
    NSRange range2=[result rangeOfString:@"login_time"];
    if (range.location!=NSNotFound) {
        //提示没有此用户
        NSLog(@"there is no user");
    }
    if (range1.location!=NSNotFound) {
        //提示密码错误
        NSLog(@"the password is wrong");
    }
    if (range2.location!=NSNotFound) {
        //登陆成功
        //根据返回的role确定用户类型
        [self performSegueWithIdentifier:@"ShowColFromLogin" sender:nil];
    }
    
    NSLog(@"%@",result);
}

- (IBAction)loginClicked:(id)sender {
//    [self judgeLoginInfo];
    [self performSegueWithIdentifier:@"ShowColFromLogin" sender:nil];

}
- (IBAction)registerClicked:(id)sender {
    //弹出uiWebView
     self.registerWeb=[[UIWebView alloc]initWithFrame:CGRectMake(1024, 20, 900, 748)];
    NSURL *htmlURL=[NSURL URLWithString:@"http://159.226.15.218:50080/sjyfi/reg.jsp"];
    NSURLRequest *request=[[NSURLRequest alloc] initWithURL:htmlURL];
    
    [self.registerWeb loadRequest:request];
    [self.registerWeb setUserInteractionEnabled:YES];
    [self.view addSubview:self.registerWeb];
    [self.view addSubview:self.registerWeb];
    CGContextRef context=UIGraphicsGetCurrentContext();
    [UIView beginAnimations:@"ShowRegisterPage" context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.7];
    CGRect frame=self.registerWeb.frame;
    frame.origin.x -=700;
    [self.registerWeb setFrame:frame];
    [UIView commitAnimations];
    self.showRegister=YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if (self.showRegister) {
        //hide web
        [UIView animateWithDuration:0.7 animations:^{
            CGRect frame=self.registerWeb.frame;
            frame.origin.x +=700;
            [self.registerWeb setFrame:frame];
        } completion:^(BOOL finished) {
            nil;
        }];
    }
}

#pragma mark -Check NetWork
-(void)checkReachability{
    Reachability *r=[Reachability reachabilityWithHostName:@"www.baidu.com"];
    switch ([r currentReachabilityStatus]) {
        case NotReachable:
            self.nameLabel.text=@"记录人";
            [self toastNoNet];
            break;
        case ReachableViaWiFi:
            NSLog(@"there is wifi");
            break;
        default:
            break;
    }
}

-(void)toastNoNet{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"您当前没有网络连接,密码可以为空,请填写记录人后继续" delegate:self cancelButtonTitle:@"植物" otherButtonTitles:@"动物", nil];
    [alert show];
}


@end
