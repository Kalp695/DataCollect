//
//  ViewController.m
//  DataCollect
//
//  Created by liucc on 13-12-16.
//  Copyright (c) 2013年 liucc. All rights reserved.
//

#import "ViewController.h"
#import "GetTemplateInfo.h"
#import "ASIFormDataRequest.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
//    GetTemplateInfo *getInfo=[[GetTemplateInfo alloc]init];
//    [getInfo parseTset];
    NSMutableArray *testArray=[[GetTemplateInfo templateAccess]getAniTemInfoFromTp];
    NSLog(@"the count is %d",testArray.count);
    
//    [self upload];
    
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)upload{
    [_request cancel];
    //	[self setRequest:[ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"http://allseeing-i.com/ignore"]]];
    [self setRequest:[ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"http://159.226.15.215:8081/samples/apk/Upload.jsp"]]];
//    [self setRequest:[ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"http://159.226.15.218:50080/sjyfi/save.jsp"]]];
    
	[_request setPostValue:@"test" forKey:@"value1"];
	[_request setPostValue:@"test" forKey:@"value2"];
	[_request setPostValue:@"test" forKey:@"value3"];
	[_request setTimeOutSeconds:20];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
	[_request setShouldContinueWhenAppEntersBackground:YES];
#endif
//	[request setUploadProgressDelegate:progressIndicator];
	[_request setDelegate:self];
//	[request setDidFailSelector:@selector(uploadFailed:)];
//	[request setDidFinishSelector:@selector(uploadFinished:)];
	
	//Create a 256KB file
    //	NSData *data = [[[NSMutableData alloc] initWithLength:256*1024] autorelease];
    NSString *data=@"this is a up load test";
	NSString *path = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"liucctest"];
    //	[data writeToFile:path atomically:NO];
    [data writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:nil];
    
    
    NSString *zipPath=[[NSBundle mainBundle]pathForResource:@"t_sjyfi_aib&aid_20140110_111348" ofType:@"zip"];
	
	//Add the file 8 times to the request, for a total request size around 2MB
    //	int i;
    //	for (i=0; i<8; i++) {
    //		[request setFile:path forKey:[NSString stringWithFormat:@"file-%i",i]];
    //	}
    [_request setFile:zipPath forKey:@"file-zip"];
    
	
	[_request startAsynchronous];
//	[resultView setText:@"Uploading data..."];
}
//@synthesize request;



@end
