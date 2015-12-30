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
#import "RecordVoice.h"
#import "amrFileCodec.h"
@interface ViewController ()<AVAudioRecorderDelegate>
{
    UIProgressView *_audioPower;//音频波动
    RecordVoice *recordVoice;
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
    
    recordVoice = [[RecordVoice alloc] init];
    recordVoice.progress = ^(float progress){
        [weakSelf refreshProgress:progress];
    };
    
}
#pragma mark --获取到amr data字节


- (void)recordVoice{
    startRecordTime = [NSDate timeIntervalSinceReferenceDate];
    [recordVoice recordVioce];
}
- (void)stopVoice{
    endRecordTime = [NSDate timeIntervalSinceReferenceDate];
    endRecordTime -= startRecordTime;
    [_audioPower setProgress:0.0];
    NSURL *fileUrl = [recordVoice stopVioce];

    if (endRecordTime<2.00f) {
        return;
    } else if (endRecordTime>30.00f){
        return;
    }
    
    /** 获取时间 */
    NSData *data = [RecordVoice encodeWAVEToAMROfFile:fileUrl];
    NSString *time = [RecordVoice getAudioTime:data];

    /** 大于2s秒小于30s写入Document */
    if (data.length>0) {
        [recordVoice writeToAmrFile:fileUrl amrData:data call:^(BOOL success) {
            if (success) {
                NSLog(@"写入成功");
            }
        }];
    }

    [recordVoice playAmrData:data];
 }
- (void)refreshProgress:(CGFloat)progress{
    [_audioPower setProgress:progress];
}

@end
