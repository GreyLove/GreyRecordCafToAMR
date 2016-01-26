//
//  ViewController.m
//  VoiceRecord
//
//  Created by 好价网络科技有限公司 on 15/12/15.
//  Copyright © 2015年 Grey. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "RecordButton.h"

#import "RecordManager.h"
@interface ViewController ()<AVAudioRecorderDelegate>
{
    UIProgressView *_audioPower;//音频波动
}
@end
static double startRecordTime=0;
static double endRecordTime=0;

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _audioPower = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 400, CGRectGetWidth(self.view.bounds), 20)];
    [self.view addSubview:_audioPower];
    
    RecordButton *button = [RecordButton createRecord:CGRectMake(0, 0, 0, 0)];
    [self.view addSubview:button];
    __weak __typeof(self) weakSelf = self;

    button.recordClickBlock = ^(){
        NSLog(@"录音了..");
        [weakSelf recordVoice];
    };
    button.stopClickBlock = ^(){
       
        NSLog(@"停止录音了..");
        [weakSelf stopVoice];
    };
    
    button.cancleClickBlock = ^(){
        NSLog(@"取消录音");
        [weakSelf cancelRecored];
    };
    [RecordManager shareManager].progress = ^(float progress){
        [weakSelf refreshProgress:progress];
    };
    
}
#pragma mark --获取到amr data字节


- (void)recordVoice{
    startRecordTime = [NSDate timeIntervalSinceReferenceDate];
    [[RecordManager shareManager] startTalkVoice:@"3"];
}
- (void)stopVoice{
    endRecordTime = [NSDate timeIntervalSinceReferenceDate];
    endRecordTime -= startRecordTime;
    NSURL *url = [[RecordManager shareManager] stopTalkVoice];

    [_audioPower setProgress:0.0];

    if (endRecordTime<2.00f) {
        return;
    } else if (endRecordTime>30.00f){
        return;
    }

    NSData *data = [NSData dataWithContentsOfURL:url];
    
    /** 获取时间 */
    NSString *time = [[RecordManager shareManager] getAudioTime:data];
    NSLog(@"%@",time);


    __weak __typeof(self) weakSelf = self;

    [[RecordManager shareManager] writeAuToAmrFile:url callback:^(BOOL success, NSData *amrData) {
        if (success) {
            [weakSelf play:amrData];

        }
    }];
 }

- (void)cancelRecored{
    [[RecordManager shareManager] cancelTalkVoice];
}
- (void)play:(NSData*)data{
//    NSData *data = [NSData dataWithContentsOfFile:path];
   [[RecordManager shareManager] playAmrData:data];
}

- (void)refreshProgress:(CGFloat)progress{
    [_audioPower setProgress:progress];
}

@end
