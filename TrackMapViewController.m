//
//  TrackMapViewController.m
//  DataCollect
//
//  Created by liucc on 2/18/14.
//  Copyright (c) 2014 liucc. All rights reserved.
//

#import "TrackMapViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <iOS-KML-Framework/KML.h>
#import "TrackPoint.h"
#import <DDXML.h>
#import "NSString+EncodingUTF8Additions.h"
#import "SSZipArchive.h"



#import "CoreDataStore.h"
#import "Functions.h"
#import "NSManagedObject+InnerBand.h"

#import "WidgetView.h"
#import <AVFoundation/AVFoundation.h>

@interface TrackMapViewController ()
@property(nonatomic,strong)UIDocumentInteractionController *interactionController;
@property(nonatomic,strong)CLLocationManager *locationManager;

@property(nonatomic,strong)TrackPoint *currentTrackPoint;

@property(nonatomic,strong)WidgetView *widView;

@property(nonatomic,strong)NSString *videoDir;
@property(nonatomic,strong)NSString *imgDir;

@property(nonatomic,strong)NSString *beginTime;
@property(nonatomic,strong)NSString *endTime;

-(void)startLogging;
-(void)showLog;
@end

@interface TrackMapViewController(CLLocationManagerDelegate)<CLLocationManagerDelegate>
@end

@interface TrackMapViewController (MKMapViewDelegate) <MKMapViewDelegate>
- (void)updateOverlay;
@end

@interface TrackMapViewController(UIActionSheetDelegate)<UIActionSheetDelegate>
-(NSString *)kmlFilePath;
-(NSString *)createKML;
-(KMLPlacemark *)placemarkWithName:(NSString *)name coordinate:(CLLocationCoordinate2D)coordinate;
-(KMLPlacemark *)lineWithTrackPoints:(NSArray *)trackPoints;
-(void)openFile:(NSString *)filePath;
//-(void)mailFile:(NSString *)filePath;
@end

@interface TrackMapViewController(WidgetDelegate) <WidgetDelegate>
-(void)saveContentToSql;
@end

@interface TrackMapViewController(UIImagePickerControllerDelegate)<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@end


@implementation TrackMapViewController

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
    if (!self.track) {
        [self startLogging];
        [self addRightBtnToNav];
        self.mapView.showsUserLocation=YES;
    }else{
        [self showLog];
        self.mapView.showsUserLocation=NO;

    }
}
- (IBAction)close:(id)sender
{
    if (self.locationManager) {
        [self.locationManager stopUpdatingLocation];
        //生成kml并压缩成kmz格式
        [self createKML];
        
        //结束时间
        NSDateFormatter *formatter=[NSDateFormatter new];
        [formatter setTimeStyle:NSDateFormatterFullStyle];
        [formatter setDateFormat:@"yyyyMMddHHmmss"];
        NSString *dateString=[formatter stringFromDate:[NSDate new]];
        self.endTime=dateString;
        
        
        //生成描述文件trackDetailXml create
        [self createDetailXml];
        
        //压缩
        [self createZip];
        
    }
    [self.navigationController popViewControllerAnimated:YES];

}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    if (self.locationManager) {
        [self createDir];
        //开始时间
        NSDateFormatter *formatter=[NSDateFormatter new];
        [formatter setTimeStyle:NSDateFormatterFullStyle];
        [formatter setDateFormat:@"yyyyMMddHHmmss"];
        NSString *dateString=[formatter stringFromDate:[NSDate new]];
        self.beginTime=dateString;
    }

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Private methods

-(void)createDir{
    //生成文件夹
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath=[paths firstObject];
    NSString *listPath=[documentPath stringByAppendingPathComponent:@"trackList"];
    NSFileManager *fileManager=[NSFileManager defaultManager];
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setTimeStyle:NSDateFormatterFullStyle];
    formatter.dateFormat = @"yyyy-MM-dd hh:mm:ss";
    NSString *title = [formatter stringFromDate:self.track.created];
//    self.timeStamp=title;
    
    NSString *dateDirPath=[listPath stringByAppendingPathComponent:title];
    [fileManager createDirectoryAtPath:dateDirPath withIntermediateDirectories:YES attributes:nil error:nil];
    self.dirPath=dateDirPath;
    
    
    NSString *videoPath=[dateDirPath stringByAppendingPathComponent:@"Video"];
    NSString *imgPath=[dateDirPath stringByAppendingPathComponent:@"Photo"];
    [fileManager createDirectoryAtPath:videoPath withIntermediateDirectories:YES attributes:nil error:nil];
    [fileManager createDirectoryAtPath:imgPath withIntermediateDirectories:YES attributes:nil error:nil];
    self.videoDir=videoPath;
    self.imgDir=imgPath;
}

-(void)addRightBtnToNav{
    UIBarButtonItem *rightBtn=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addkeyPoint)];
    self.navigationItem.rightBarButtonItem=rightBtn;
}
-(void)addkeyPoint{
     self.widView=[[WidgetView alloc]initWithFrame:CGRectMake(1024, self.navigationController.navigationBar.frame.size.height, 320, 768)];
    self.widView.delegate=self;
    [self.view addSubview:self.widView];
    self.widView.alpha=0.1;
    CGContextRef context=UIGraphicsGetCurrentContext();
    [UIView beginAnimations:@"ShowWidget" context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.7];
    
    CGRect frame=self.widView.frame;
    frame.origin.x -=320;
    [self.widView setFrame:frame];
    self.widView.alpha=1.0;
    
    [UIView commitAnimations];
    
    
    //产生一个时间戳 self.timestamp=[nsdate date]stringvalue;
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setTimeStyle:NSDateFormatterFullStyle];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    self.timeStamp=dateString;
}

- (void)startLogging
{
    // initialize map position
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(39.977887, 116.329404);
    MKCoordinateSpan span = MKCoordinateSpanMake(0.05f, 0.05f);
    MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, span);
    [self.mapView setRegion:region];
    
    // initialize location manager
    if (![CLLocationManager locationServicesEnabled]) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                            message:NSLocalizedString(@"Location Service not enabeld.", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                  otherButtonTitles:nil];
        [alertView show];
        
    } else {
        self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"Stop Logging", nil);
        
        self.locationManager = [CLLocationManager new];
        self.locationManager.delegate = self;
        [self.locationManager startUpdatingLocation];
        
        self.track = [Track create];
        self.track.created = [NSDate date];
        [[CoreDataStore mainStore] save];
    }
}

- (void)showLog
{
    [self updateOverlay];
    MKMapRect zoomRect = MKMapRectNull;
    for (TrackPoint *trackPoint in self.track.trackpoints) {
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(trackPoint.latitude.floatValue, trackPoint.longitude.floatValue);
        MKMapPoint annotationPoint = MKMapPointForCoordinate(coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
        if (MKMapRectIsNull(zoomRect)) {
            zoomRect = pointRect;
        } else {
            zoomRect = MKMapRectUnion(zoomRect, pointRect);
        }
    }
    [self.mapView setVisibleMapRect:zoomRect animated:NO];
}


-(void)createDetailXml{
    DDXMLElement *ele_root=[DDXMLElement elementWithName:@"trackdetail"];
    DDXMLElement *name_node=[DDXMLElement elementWithName:@"name"];
    [name_node setStringValue:@"track Name"];
    DDXMLElement *author_node=[DDXMLElement elementWithName:@"author" stringValue:@"dante"];
    DDXMLElement *starttime_node=[DDXMLElement elementWithName:@"starttime" stringValue:self.beginTime];
    DDXMLElement *endtime_node=[DDXMLElement elementWithName:@"endtime" stringValue:self.endTime];
    DDXMLElement *length_node=[DDXMLElement elementWithName:@"length" stringValue:[self caculateLength] ];
    DDXMLElement *maxaltitude_node=[DDXMLElement elementWithName:@"maxaltitude" stringValue:[self caculateMaxAltitude] ];
    
    //获得所有标记过的关键点
    NSArray *originalKeyPoints=self.track.sotredTrackPoints;
    NSMutableArray *keyPoints=[@[]mutableCopy];
    NSLog(@"the original count %lu",(unsigned long)originalKeyPoints.count);
    for (TrackPoint *keyPoint in originalKeyPoints) {
        if (keyPoint.keyIndex) {
            [keyPoints addObject:keyPoint];
        }
    }
    NSLog(@"the keypoints count %d",keyPoints.count);
    NSMutableArray *keysiteslist=[[NSMutableArray alloc]init];
    for (int i=0; i<keyPoints.count; i++) {
        TrackPoint *point=[keyPoints objectAtIndex:i];
        NSString *name=[NSString stringWithFormat:@"%@ %@ %@",[point.longitude stringValue],[point.latitude stringValue],[point.altitude stringValue]];
        [keysiteslist addObject:name];
    }
    NSString *keyPointsString=[keysiteslist componentsJoinedByString:@","];
    
    DDXMLElement *keysiteslist_node=[DDXMLElement elementWithName:@"keysiteslist" stringValue:keyPointsString];
    DDXMLElement *annotation_node=[DDXMLElement elementWithName:@"annotation" stringValue:@"annotation"];
    [ele_root addChild:name_node];
    [ele_root addChild:author_node];
    [ele_root addChild:starttime_node];
    [ele_root addChild:endtime_node];
    [ele_root addChild:length_node];
    [ele_root addChild:maxaltitude_node];
    [ele_root addChild:keysiteslist_node];
    [ele_root addChild:annotation_node];
    
    NSString *fileNaeme=@"TrackDetail.xml";
    NSString *xmlString=[NSString replaceUnicode:[ele_root XMLString]];
    NSMutableString *mutableXmlString=[xmlString mutableCopy];
    NSString *path=[self.dirPath stringByAppendingPathComponent:fileNaeme];
    [mutableXmlString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
}
-(NSString *)caculateLength{
    NSArray *trackPoints=self.track.sotredTrackPoints;
    CLLocationDistance meters=0.00;
    for (int i=0,j=1; i<trackPoints.count-1; i++,j++) {
        TrackPoint *t1=[trackPoints objectAtIndex:i];
        TrackPoint *t2=[trackPoints objectAtIndex:j];
        CLLocation *previous=[[CLLocation alloc]initWithLatitude:[t1.latitude floatValue] longitude:[t1.longitude floatValue ]];
        CLLocation *next=[[CLLocation alloc]initWithLatitude:[t2.latitude floatValue] longitude:[t2.longitude floatValue]];
        //计算距离
        CLLocationDistance meter=[next distanceFromLocation:previous];
        meters +=meter;
    }
    
    NSString *length=[NSString stringWithFormat:@"%f",meters];
    return length;
}
-(NSString *)theReturnTest{
    NSString *test;
    
    return test;
}

-(NSString *)caculateMaxAltitude{
    NSArray *trackPoints=self.track.sotredTrackPoints;
    double maxAltitude=0.00;
    for (int i=0; i<trackPoints.count; i++) {
        TrackPoint *point=[trackPoints objectAtIndex:i];
        double altitude=[point.altitude floatValue];
        if (altitude>=maxAltitude) {
            maxAltitude=altitude;
        }
    }
    NSString *altitude=[NSString stringWithFormat:@"%f",maxAltitude];
    return altitude;
}

-(void)createZip{
    NSString *filePaht=self.dirPath;
    NSLog(@"%@",filePaht);
    NSArray *inputsPaths=[NSArray arrayWithObjects:filePaht, nil];
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath=[paths firstObject];
    NSString *test=[documentPath stringByAppendingPathComponent:@"test.zip"];

    
    [SSZipArchive createZipFileAtPath:test withContentsOfDirectory:filePaht];
}




@end



#pragma mark -
@implementation TrackMapViewController(CLLocationManagerDelegate)
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if (newLocation) {
        TrackPoint *trackpoint = [TrackPoint create];
        trackpoint.latitude = [NSNumber numberWithFloat:newLocation.coordinate.latitude];
        trackpoint.longitude = [NSNumber numberWithFloat:newLocation.coordinate.longitude];
        trackpoint.altitude = [NSNumber numberWithFloat:newLocation.altitude];
        trackpoint.created = [NSDate date];
        [self.track addTrackpointsObject:trackpoint];
        self.currentTrackPoint=trackpoint;
        
        [[CoreDataStore mainStore] save];
        NSLog(@"new location %f %f",newLocation.coordinate.longitude,newLocation.coordinate.latitude);
        // update annotation and overlay
        [self updateOverlay];
        
        // set new location as center
        [self.mapView setCenterCoordinate:newLocation.coordinate animated:YES];
        
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
    [alertView show];
    
    [self.locationManager stopUpdatingLocation];
}

@end

#pragma mark -
@implementation TrackMapViewController(WidgetDelegate)
-(void)capturePicAction{
    UIImagePickerController *imgPicker=[[UIImagePickerController alloc]init];
    imgPicker.delegate=self;
    imgPicker.sourceType=UIImagePickerControllerSourceTypeCamera;
    imgPicker.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
    imgPicker.allowsEditing=NO;
    [self presentViewController:imgPicker animated:YES completion:nil];

}
-(void)captureVideoAction{
    UIImagePickerController *videoPicker=[[UIImagePickerController alloc]init];
    videoPicker.delegate=self;
    videoPicker.sourceType=UIImagePickerControllerSourceTypeCamera;
//    videoPicker.mediaTypes=[UIImagePickerController availableCaptureModesForCameraDevice:UIImagePickerControllerSourceTypeCamera];
    videoPicker.mediaTypes=[[NSArray alloc]initWithObjects:(NSString *) kUTTypeMovie, nil];
    [self presentViewController:videoPicker animated:YES completion:nil];
    
}


-(void)captureAudioAction{
 
}



-(void)saveContentToSql{
    //将当前关键点的照片、描述、以及视频路径插入到数据库
    //self.currentTrackPoint.keyIndex=self.stamp;self.currenttrackPoint.imagePath=self.timestamp.jpg
    NSString *imgPath=[NSString stringWithFormat:@"Photo/%@.png",self.timeStamp];
    self.currentTrackPoint.keyIndex=self.timeStamp;
    self.currentTrackPoint.imagepath=imgPath;
    self.currentTrackPoint.script=self.widView.description;
    [[CoreDataStore mainStore]save];
}


@end

#pragma mark -
@implementation TrackMapViewController(UIImagePickerControllerDelegate)
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image=[info objectForKey:UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImageView *imgView=[[UIImageView alloc]initWithFrame:self.widView.picView.bounds];
    [imgView setImage:image];
    [self.widView.picView addSubview:imgView];
    //将照片和视频储存到文件中，照片的文件名是时间戳 video.name=self.timestamp;
    NSString *imgPath=[self.imgDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",self.timeStamp]];
    [UIImagePNGRepresentation(image) writeToFile:imgPath atomically:YES];
    
    
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
@end



#pragma mark -
@implementation TrackMapViewController(MKMapViewDelegate)
- (void)updateOverlay
{
    if (!self.track) {
        return;
    }
    NSArray *trackPoints = self.track.sotredTrackPoints;
    
    CLLocationCoordinate2D coors[trackPoints.count];
    
    int i = 0;
    for (TrackPoint *trackPoint in trackPoints) {
        coors[i] = trackPoint.coordinate;
        i++;
    }
    
    MKPolyline *line = [MKPolyline polylineWithCoordinates:coors count:trackPoints.count];
    
    // replace overlay
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView addOverlay:line];
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    MKPolylineView *overlayView = [[MKPolylineView alloc] initWithOverlay:overlay];
    overlayView.strokeColor = [UIColor blueColor];
    overlayView.lineWidth = 5.f;
    
    return overlayView;
}
@end

#pragma mark -
@implementation TrackMapViewController (UIActionSheetDelegate)

- (NSString *)kmlFilePath
{
    
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setTimeStyle:NSDateFormatterFullStyle];
    formatter.dateFormat = @"yyyy-MM-dd hh:mm:ss";
    NSString *dateString = [formatter stringFromDate:self.track.created];
    
    NSString *fileName = [NSString stringWithFormat:@"log_%@.kml", dateString];
    return [self.dirPath stringByAppendingPathComponent:fileName];
}

- (NSString *)createKML
{
    NSLog(@"%@",NSTemporaryDirectory());
    
    // kml
    KMLRoot *kml = [KMLRoot new];
    
    // kml > document
    KMLDocument *document = [KMLDocument new];
    kml.feature = document;
    
    NSArray *sortedTrackPoints = self.track.sotredTrackPoints;
    
    // kml > document > placemark#strat
    TrackPoint *startPoint = [sortedTrackPoints objectAtIndex:0];
    KMLPlacemark *startPlacemark = [self placemarkWithName:@"Start" coordinate:startPoint.coordinate];
    [document addFeature:startPlacemark];
    
    
    //测试一个热点
//    for (TrackPoint *keyPoint in sortedTrackPoints) {
//        if (keyPoint.keyIndex) {
//            KMLPlacemark *keyPlaceMark=[self placemarkWithName:[NSString stringWithFormat:@"Lon:%@,Lat:%@",keyPoint.longitude,keyPoint.latitude] coordinate:keyPoint.coordinate ];
//            keyPlaceMark.descriptionValue=@"this is a description test";
//            [document addFeature:keyPlaceMark];
//        }
//    }
    
    // kml > document > placemark#line
    KMLPlacemark *line = [self lineWithTrackPoints:sortedTrackPoints];
    [document addFeature:line];
    
    // kml > document > placemark#end
    TrackPoint *endPoint = [sortedTrackPoints lastObject];
    KMLPlacemark *endPlacemark = [self placemarkWithName:@"End" coordinate:endPoint.coordinate];
    [document addFeature:endPlacemark];
    
    NSString *kmlString = kml.kml;
    
    // write kml to file
    NSError *error;
    NSString *filePath = [self kmlFilePath];
    if (![kmlString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
        if (error) {
            NSLog(@"error, %@", error);
        }
        return nil;
    }
    return filePath;
}

- (KMLPlacemark *)placemarkWithName:(NSString *)name coordinate:(CLLocationCoordinate2D)coordinate
{
    KMLPlacemark *placemarkElement = [KMLPlacemark new];
    placemarkElement.name = name;
    
    
    KMLPoint *pointElement = [KMLPoint new];
    placemarkElement.geometry = pointElement;
    
    KMLCoordinate *coordinateElement = [KMLCoordinate new];
    coordinateElement.latitude = coordinate.latitude;
    coordinateElement.longitude = coordinate.longitude;
    pointElement.coordinate = coordinateElement;
    
    return placemarkElement;
}

- (KMLPlacemark *)lineWithTrackPoints:(NSArray *)trackPoints
{
    KMLPlacemark *placemark = [KMLPlacemark new];
    placemark.name = @"Line";
    
    KMLLineString *lineString = [KMLLineString new];
    placemark.geometry = lineString;
    
    for (TrackPoint *trackPoint in trackPoints) {
        KMLCoordinate *coordinate = [KMLCoordinate new];
        coordinate.latitude = trackPoint.coordinate.latitude;
        coordinate.longitude = trackPoint.coordinate.longitude;
        [lineString addCoordinate:coordinate];
    }
    
    KMLStyle *style = [KMLStyle new];
    [placemark addStyleSelector:style];
    
    KMLLineStyle *lineStyle = [KMLLineStyle new];
    style.lineStyle = lineStyle;
    lineStyle.width = 5;
    lineStyle.UIColor = [UIColor blueColor];
    
    return placemark;
}

- (void)openFile:(NSString *)filePath
{
    NSURL *url = [NSURL fileURLWithPath:filePath];
    self.interactionController = [UIDocumentInteractionController interactionControllerWithURL:url];
    
    if (![self.interactionController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                        message:NSLocalizedString(@"No application can be found to open the file.", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }
}


@end































