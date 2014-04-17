//
//  WidgetView.h
//  DataCollect
//
//  Created by liucc on 3/7/14.
//  Copyright (c) 2014 liucc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol WidgetDelegate <NSObject>

@optional
-(void)capturePicAction;
-(void)captureVideoAction;
-(void)captureAudioAction;
-(void)saveContentToSql;
@end



@interface WidgetView : UIView{
    
    IBOutlet UIImageView *soundLodingImageView;
    //录音器
    AVAudioRecorder *recorder;
    //播放器
    AVAudioPlayer *player;
    NSDictionary *recorderSettingsDict;
    
    //定时器
    NSTimer *timer;
    //图片组
    NSMutableArray *volumImages;
    double lowPassResults;
    
    //录音名字
    NSString *playName;

}

@property(nonatomic,strong)IBOutlet UIView *view;
@property(nonatomic,strong)id<WidgetDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIView *picView;
@property (strong, nonatomic) IBOutlet UIView *videoView;
@property (strong, nonatomic) IBOutlet UITextView *descripView;

@end
