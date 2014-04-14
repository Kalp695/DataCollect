//
//  OfflineDetailViewController.m
//  Category_demo
//
//  Created by songjian on 13-7-9.
//  Copyright (c) 2013年 songjian. All rights reserved.
//

#import "OfflineDetailViewController.h"
#import <MAMapKit/MAMapKit.h>

#define kDefaultSearchkey @"北"

NSString const *DownloadStageIsRunningKey = @"DownloadStageIsRunningKey";
NSString const *DownloadStageStatusKey    = @"DownloadStageStatusKey";
NSString const *DownloadStageInfoKey      = @"DownloadStageInfoKey";

@interface OfflineDetailViewController (SearchCity)

/* Returns a new array consisted of MAOfflineCity object for which match the key. */
- (NSArray *)citiesFilterWithKey:(NSString *)key;

@end

@interface OfflineDetailViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *cities;
@property (nonatomic, strong) NSMutableArray *downloadStages;

@property (nonatomic, strong) NSPredicate *predicate;

@property (nonatomic, assign) BOOL needReloadWhenDidAppear;

@end

@implementation OfflineDetailViewController
@synthesize mapView   = _mapView;
@synthesize tableView = _tableView;
@synthesize cities    = _cities;
@synthesize downloadStages = _downloadStages;
@synthesize predicate = _predicate;
@synthesize needReloadWhenDidAppear = _needReloadWhenDidAppear;

#pragma mark - Utility

- (void)checkNewestVersionAction
{
    [[MAOfflineMap sharedOfflineMap] checkNewestVersion:^(BOOL hasNewestVersion) {
        
        if (!hasNewestVersion)
        {
            return;
        }
        
        /* Manipulations to your application's user interface must occur on the main thread. */
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self setupTitle];
            
            [self setupCities];
            
            [self.tableView reloadData];
        });
    }];
}

- (UIButton *)newButtonWithTitle:(NSString *)title
                          target:(id)target
                        selector:(SEL)selector
                           frame:(CGRect)frame
                           image:(UIImage *)image
                    imagePressed:(UIImage *)imagePressed
{
	UIButton *button = [[UIButton alloc] initWithFrame:frame];
	
	button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	
	[button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	
	UIImage *newImage = [image stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	[button setBackgroundImage:newImage forState:UIControlStateNormal];
	
	UIImage *newPressedImage = [imagePressed stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	[button setBackgroundImage:newPressedImage forState:UIControlStateHighlighted];
	
	[button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
	
	button.backgroundColor = [UIColor clearColor];
	
	return button;
}

- (UIButton *)downloadButton
{
    return [self newButtonWithTitle:nil
                             target:self
                           selector:@selector(checkButtonTapped:event:)
                              frame:CGRectMake(0, 0, 60.f, 40.f)
                              image:[UIImage imageNamed:@"whiteButton.png"]
                       imagePressed:[UIImage imageNamed:@"blueButton.png"]];
    
}

- (NSIndexPath *)indexPathForSender:(id)sender event:(UIEvent *)event
{
    UIButton *button = (UIButton*)sender;
    
    UITouch *touch = [[event allTouches] anyObject];
    
    if (![button pointInside:[touch locationInView:button] withEvent:event])
    {
        return nil;
    }
    
    CGPoint touchPosition = [touch locationInView:self.tableView];
    
    return [self.tableView indexPathForRowAtPoint:touchPosition];
}

- (NSString *)cellLabelTextForCity:(MAOfflineCity *)city downloadStage:(NSDictionary *)downloadStage
{
    NSString *labelText = nil;
    
    if ([[downloadStage objectForKey:DownloadStageIsRunningKey] boolValue])
    {
        labelText = city.cityName;
    }
    else
    {
        if (city.status == MAOfflineCityStatusInstalled)
        {
            labelText = [city.cityName stringByAppendingString:@"(已安装)"];
        }
        else if (city.status == MAOfflineCityStatusExpired)
        {
            labelText = [city.cityName stringByAppendingString:@"(有更新)"];
        }
        else if (city.status == MAOfflineCityStatusCached)
        {
            labelText = [city.cityName stringByAppendingString:@"(缓存)"];
        }
        else
        {
            labelText = city.cityName;
        }
    }
    
    return labelText;
}

- (NSString *)cellDetailTextForCity:(MAOfflineCity *)city downloadStage:(NSDictionary *)downloadStage
{
    NSString *detailText = nil;
    
    if (![[downloadStage objectForKey:DownloadStageIsRunningKey] boolValue])
    {
        if (city.status == MAOfflineCityStatusCached)
        {
            detailText = [NSString stringWithFormat:@"%lld/%lld", city.downloadedSize, city.size];
        }
        else
        {
            detailText = [NSString stringWithFormat:@"大小:%lld", city.size];
        }
    }
    else
    {
        MAOfflineMapDownloadStatus status = [[downloadStage objectForKey:DownloadStageStatusKey] intValue];
        
        switch (status)
        {
            case MAOfflineMapDownloadStatusWaiting:
            {
                detailText = @"等待";
                
                break;
            }
            case MAOfflineMapDownloadStatusStart:
            {
                detailText = @"开始";
                
                break;
            }
            case MAOfflineMapDownloadStatusProgress:
            {
                NSDictionary *progressDict = [downloadStage objectForKey:DownloadStageInfoKey];
                
                long long recieved = [[progressDict objectForKey:MAOfflineMapDownloadReceivedSizeKey] longLongValue];
                long long expected = [[progressDict objectForKey:MAOfflineMapDownloadExpectedSizeKey] longLongValue];
                
                detailText = [NSString stringWithFormat:@"%lld/%lld(%.1f%%)", recieved, expected, recieved/(float)expected*100];
                break;
            }
            case MAOfflineMapDownloadStatusCompleted:
            {
                detailText = @"下载完成";
                break;
            }
            case MAOfflineMapDownloadStatusCancelled:
            {
                detailText = @"取消";
                break;
            }
            case MAOfflineMapDownloadStatusUnzip:
            {
                detailText = @"解压中";
                break;
            }
            case MAOfflineMapDownloadStatusFinished:
            {
                detailText = @"结束";
                
                break;
            }
            default:
            {
                detailText = @"错误";
                
                break;
            }
        }
    }
    
    return detailText;
}

- (void)updateAccessoryViewForCell:(UITableViewCell *)cell City:(MAOfflineCity *)city downloadStage:(NSDictionary *)downloadStage
{
    UIButton *btn = (UIButton *)cell.accessoryView;
    
    if (city.status == MAOfflineCityStatusInstalled)
    {
        btn.hidden = YES;
    }
    else
    {
        btn.hidden = NO;
        
        [btn setTitle:[[downloadStage objectForKey:DownloadStageIsRunningKey] boolValue] ? @"暂停" : @"下载"
             forState:UIControlStateNormal];
    }
}

- (void)updateCell:(UITableViewCell *)cell city:(MAOfflineCity *)city downloadStage:(NSDictionary *)downloadStage
{
    [self updateAccessoryViewForCell:cell City:city downloadStage:downloadStage];
    
    cell.textLabel.text         = [self cellLabelTextForCity:city downloadStage:downloadStage];
    
    cell.detailTextLabel.text   = [self cellDetailTextForCity:city downloadStage:downloadStage];
}

- (void)download:(NSIndexPath *)indexPath
{
    MAOfflineCity *city         = self.cities[indexPath.row];
    
    NSMutableDictionary *stage  = self.downloadStages[indexPath.row];
    
    [[MAOfflineMap sharedOfflineMap] downloadCity:city shouldContinueWhenAppEntersBackground:YES downloadBlock:^(MAOfflineMapDownloadStatus downloadStatus, id info) {
        
        /* Manipulations to your application’s user interface must occur on the main thread. */
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (downloadStatus == MAOfflineMapDownloadStatusWaiting)
            {
                [stage setObject:[NSNumber numberWithBool:YES] forKey:DownloadStageIsRunningKey];
            }
            else if(downloadStatus == MAOfflineMapDownloadStatusProgress)
            {
                [stage setObject:info forKey:DownloadStageInfoKey];
            }
            else if(downloadStatus == MAOfflineMapDownloadStatusCancelled
                    || downloadStatus == MAOfflineMapDownloadStatusError
                    || downloadStatus == MAOfflineMapDownloadStatusFinished)
            {
                [stage setObject:[NSNumber numberWithBool:NO] forKey:DownloadStageIsRunningKey];
            }
            
            [stage setObject:[NSNumber numberWithInt:downloadStatus] forKey:DownloadStageStatusKey];
            
            /* Update UI. */
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            
            if (cell != nil)
            {
                [self updateCell:cell city:city downloadStage:stage];
            }
            
            if (downloadStatus == MAOfflineMapDownloadStatusFinished)
            {
                if ([UIApplication sharedApplication].applicationState != UIApplicationStateBackground)
                {
                    self.needReloadWhenDidAppear = NO;
                    
                    [self.mapView reloadMap];
                }
                else
                {
                    self.needReloadWhenDidAppear = YES;
                }
            }
        });
    }];
}

- (void)pause:(NSIndexPath *)indexPath
{
    [[MAOfflineMap sharedOfflineMap] pause:self.cities[indexPath.row]];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cities.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cityCellIdentifier = @"cityCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cityCellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cityCellIdentifier];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.accessoryView = [self downloadButton];
    }
    
    [self updateCell:cell city:self.cities[indexPath.row] downloadStage:self.downloadStages[indexPath.row]];
    
    return cell;
}

#pragma mark - Handle Action

- (void)checkButtonTapped:(id)sender event:(id)event
{
    NSIndexPath *indexPath = [self indexPathForSender:sender event:event];
    
    if (indexPath == nil)
    {
        return;
    }
    
    MAOfflineCity *city = self.cities[indexPath.row];
    
    if ([[MAOfflineMap sharedOfflineMap] isDownloadingForCity:city])
    {
        [self pause:indexPath];
    }
    else
    {
        [self download:indexPath];
    }
}

- (void)backAction
{
    [self cancelAllAction];
    
//    [self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:^{
        nil;
    }];
}

- (void)cancelAllAction
{
    [[MAOfflineMap sharedOfflineMap] cancelAll];
}

- (void)searchAction
{
    /* 搜索关键字支持 {城市中文名称, 拼音(不区分大小写), 区号}三种类型. */
    NSString *key = kDefaultSearchkey;
    
    NSArray *result = [self citiesFilterWithKey:key];
    
    NSLog(@"key = %@, result count = %d", key, result.count);
    [result enumerateObjectsUsingBlock:^(MAOfflineCity *obj, NSUInteger idx, BOOL *stop) {
        NSLog(@"idx = %d, cityName = %@, cityCode = %@, urlString = %@, size = %lld", idx, obj.cityName, obj.cityCode, obj.urlString, obj.size);
    }];
}

#pragma mark - Initialization

- (void)initNavigationBar
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                          target:self
                                                                                          action:@selector(backAction)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消全部"
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:self
                                                                             action:@selector(cancelAllAction)];
}

- (void)initToolBar
{
    UIBarButtonItem *flexbleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                 target:self
                                                                                 action:nil];
    
    UILabel *prompts = [[UILabel alloc] init];
    prompts.text            = [NSString stringWithFormat:@"默认关键字是\"%@\", 结果在console打印", kDefaultSearchkey];
    prompts.textAlignment   = UITextAlignmentCenter;
    prompts.backgroundColor = [UIColor clearColor];
    prompts.textColor       = [UIColor whiteColor];
    prompts.font            = [UIFont systemFontOfSize:15];
    [prompts sizeToFit];
    
    UIBarButtonItem *promptsItem = [[UIBarButtonItem alloc] initWithCustomView:prompts];
    
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                                                target:self
                                                                                action:@selector(searchAction)];
    
    self.toolbarItems = [NSArray arrayWithObjects:flexbleItem, promptsItem, flexbleItem, searchItem,flexbleItem, nil];
}

- (void)initTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.delegate   = self;
    self.tableView.dataSource = self;
    
    [self.view addSubview:self.tableView];
}

- (void)setupCities
{
    self.cities = [MAOfflineMap sharedOfflineMap].offlineCities;
    
    self.downloadStages = [NSMutableArray arrayWithCapacity:self.cities.count];
    
    for (int i = 0; i < self.cities.count; i++)
    {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        
        [self.downloadStages addObject:dict];
    }
}

- (void)setupTitle
{
    self.navigationItem.title = [MAOfflineMap sharedOfflineMap].version;
}

- (void)setupPredicate
{
    self.predicate = [NSPredicate predicateWithFormat:@"cityName CONTAINS[cd] $KEY OR cityCode CONTAINS[cd] $KEY OR urlString CONTAINS[cd] $KEY"];
}

#pragma mark - Life Cycle

- (id)init
{
    self = [super init];
    if (self)
    {
        [self setupCities];
        
        [self setupPredicate];
        
        [self setupTitle];
        
        [self checkNewestVersionAction];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initNavigationBar];
    
    [self initTableView];
    
    [self initToolBar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    self.navigationController.navigationBar.barStyle    = UIBarStyleBlack;
    self.navigationController.navigationBar.translucent = NO;
    
//    self.navigationController.toolbar.barStyle      = UIBarStyleBlack;
    self.navigationController.toolbar.translucent   = NO;
    [self.navigationController setToolbarHidden:NO animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.needReloadWhenDidAppear)
    {
        [self.mapView reloadMap];
        
        self.needReloadWhenDidAppear = NO;
    }
}

@end

@implementation OfflineDetailViewController (SearchCity)

/* Returns a new array consisted of MAOfflineCity object for which match the key. */
- (NSArray *)citiesFilterWithKey:(NSString *)key
{
    if (key.length == 0)
    {
        return nil;
    }
    
    NSPredicate *keyPredicate = [self.predicate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObject:key forKey:@"KEY"]];
    
    return [self.cities filteredArrayUsingPredicate:keyPredicate];
}

@end
