//
//  AppDelegate.m
//  DataCollect
//
//  Created by liucc on 13-12-16.
//  Copyright (c) 2013年 liucc. All rights reserved.
//

#import "AppDelegate.h"
#import "Reachability.h"
#import "APIKey.h"
#import <MAMapKit/MAMapKit.h>
@implementation AppDelegate


-(NSFileManager *)fileManager{
    if (!_fileManager) {
        _fileManager=[NSFileManager defaultManager];
    }
    return _fileManager ;
}
- (void)initializeAPIKey
{
    if ([APIKey length] == 0)
    {
        NSString *name   = [NSString stringWithFormat:@"\nSDKVersion:%@\nFILE:%s\nLINE:%d\nMETHOD:%s", [MAMapServices sharedServices].SDKVersion, __FILE__, __LINE__, __func__];
        NSString *reason = [NSString stringWithFormat:@"请首先配置APIKey.h中的APIKey, 申请APIKey参考见 http://api.amap.com"];
        
        @throw [NSException exceptionWithName:name
                                       reason:reason
                                     userInfo:nil];
    }
    
    [MAMapServices sharedServices].apiKey = (NSString *)APIKey;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self initializeAPIKey];
    // Override point for customization after application launch.
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"firstStart"]){
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstStart"];
        
        NSLog(@"第一次启动");
        NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory=[paths firstObject];
        NSString *plantListDirPath=[documentsDirectory stringByAppendingPathComponent:@"plantList"];
        NSString *animalListDirPath=[documentsDirectory stringByAppendingPathComponent:@"animalList"];
        NSString *trackListDirPath=[documentsDirectory stringByAppendingPathComponent:@"trackList"];
        NSString *downloadedKmzDirPath=[documentsDirectory stringByAppendingPathComponent:@"dlKmzList"];
//        NSString *trackSearchResultsListDirPath=[documentsDirectory stringByAppendingString:@"trackSearchResultsList"];
        
        [self.fileManager createDirectoryAtPath:plantListDirPath withIntermediateDirectories:YES attributes:nil error:nil];
        [self.fileManager createDirectoryAtPath:animalListDirPath withIntermediateDirectories:YES attributes:nil error:nil];
        [self.fileManager createDirectoryAtPath:trackListDirPath withIntermediateDirectories:YES attributes:nil error:nil];
        [self.fileManager createDirectoryAtPath:downloadedKmzDirPath withIntermediateDirectories:YES attributes:nil error:nil];

        
    }else{
        NSLog(@"不是第一次启动");
//        NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *documentsDirectory=[paths firstObject];
//        NSString *listDirPath=[documentsDirectory stringByAppendingPathComponent:@"list2"];
//        [self.fileManager createDirectoryAtPath:listDirPath withIntermediateDirectories:YES attributes:nil error:nil];
        //todo List

    }

    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
