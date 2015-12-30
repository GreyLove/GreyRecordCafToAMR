//
//  RecordVoice.m
//  VoiceRecord
//
//  Created by 好价网络科技有限公司 on 15/12/25.
//  Copyright © 2015年 Grey. All rights reserved.
//

#import "RecordVoice.h"
#import <AVFoundation/AVFoundation.h>
#import "amrFileCodec.h"

@interface RecordVoice()<AVAudioRecorderDelegate>
{
    NSData *curAudio;
    NSURL *tempFile;
}
@property (nonatomic,strong) NSTimer *timer;//录音声波监控（注意这里暂时不对播放进行监控）

@end

@implementation RecordVoice
{
    //录音
    AVAudioRecorder *_audioRecorder;
    
    //音频播放器，用于播放录音文件
    AVAudioPlayer *_audioPlayer;
}

- (id)init{
    if (self = [super init]) {
        [self setAudioSession];
    }
    return self;
}

-(void)setAudioSession{
    AVAudioSession *audioSession=[AVAudioSession sharedInstance];
    //设置为播放和录音状态，以便可以在录制完之后播放录音
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];
 

}
/**
 *  取得录音文件保存路径
 *
 *  @return 录音文件路径
 */
-(NSURL *)getSavePath{
    NSString *tmpDir =  NSTemporaryDirectory();
    /** 当前时间搓 */
    NSString *timeSp = [NSString stringWithFormat:@"%.f",[[NSDate date] timeIntervalSince1970]];
    NSString *cafFlileStr = [NSString stringWithFormat:@"%@.caf",timeSp];
    tmpDir=[tmpDir stringByAppendingPathComponent:cafFlileStr];
    NSLog(@"file path---:%@",tmpDir);
    NSURL *url=[NSURL fileURLWithPath:tmpDir];
    return url;
}

/**
 *  取得录音文件设置
 *
 *  @return 录音设置
 */
-(NSDictionary *)getAudioSetting{
//    NSMutableDictionary *dicM=[NSMutableDictionary dictionary];
//    //设置录音格式
//    [dicM setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
//    //设置录音采样率，8000是电话采样率，对于一般录音已经够了
//    [dicM setObject:@(8000) forKey:AVSampleRateKey];
//    //设置通道,这里采用单声道
//    [dicM setObject:@(1) forKey:AVNumberOfChannelsKey];
//    //每个采样点位数,分为8、16、24、32
//    [dicM setObject:@(16) forKey:AVLinearPCMBitDepthKey];
//    //是否使用浮点数采样
//    [dicM setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
//    //....其他设置等
//    return dicM;
    NSDictionary *recordSetting = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
                                   //[NSNumber numberWithFloat:44100.0], AVSampleRateKey,
                                   [NSNumber numberWithFloat:8000.00], AVSampleRateKey,
                                   [NSNumber numberWithInt:1], AVNumberOfChannelsKey,
                                   //  [NSData dataWithBytes:&channelLayout length:sizeof(AudioChannelLayout)], AVChannelLayoutKey,
                                   [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
                                   [NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
                                   [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                                   [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,
                                   nil];
    return recordSetting;
}

/**
 *  获得录音机对象
 *
 *  @return 录音机对象
 */
-(AVAudioRecorder *)setupAudioRecorder{
    
    //创建录音文件保存路径
    NSURL *url=[self getSavePath];
    /** 获取录音对象 */
    tempFile = url;
    //创建录音格式设置
    NSDictionary *setting=[self getAudioSetting];
    //创建录音机
    NSError *error=nil;
    _audioRecorder=[[AVAudioRecorder alloc]initWithURL:tempFile settings:setting error:&error];
    _audioRecorder.delegate= self;
    _audioRecorder.meteringEnabled=YES;//如果要监控声波则必须设置为YES
    if (error) {
        NSLog(@"创建录音机对象时发生错误，错误信息：%@",error.localizedDescription);
        return nil;
    }

    return _audioRecorder;
}
/**
 *  录音声波监控定制器
 *
 *  @return 定时器
 */
-(NSTimer *)timer{
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self
                                                         selector:@selector(audioPowerChange)
                                                         userInfo:nil
                                                          repeats:YES];
        /** 防止强引用 */
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return _timer;
}
/**
 *  录音声波状态设置
 */
-(void)audioPowerChange{
    [_audioRecorder updateMeters];//更新测量值
    float power= [_audioRecorder averagePowerForChannel:0];//取得第一个通道的音频，注意音频强度范围时-160到0
    CGFloat progress=(1.0/160.0)*(power+160.0);
    if (_progress) {
        _progress(progress);
    }
}
#pragma mark --录音代理
-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    NSLog(@"录音完成!");
}
/**
 *  写入文件
 */
- (void)writeToAmrFile:(NSURL*)tempFile0 amrData:(NSData*)curAudioData call:(writeSuccessBlock)block{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [paths objectAtIndex:0];
    NSString *amrName = [[[tempFile0 lastPathComponent] componentsSeparatedByString:@"."] firstObject];
    NSString *amrFile = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.amr",amrName]];
    BOOL ist = [curAudioData writeToFile:amrFile atomically:YES];
    if (block) {
        block(ist);
    }

}
/**
 *  播放
 */
- (void)playAmrData:(NSData*)data{
    NSError *error;
    /** 只能播放caf的 amr的是播放不了的*/
    _audioPlayer=[[AVAudioPlayer alloc]initWithData:DecodeAMRToWAVE(data)
                                              error:&error];
    _audioPlayer.numberOfLoops=0;
    
    [_audioPlayer prepareToPlay];
    
    if (error) {
        NSLog(@"创建播放器过程中发生错误，错误信息：%@",error.localizedDescription);
        return ;
    }
    if (![_audioPlayer isPlaying]) {
        [_audioPlayer play];
    }

}
/**
 *  录制的时间
 */
+(NSString*) getAudioTime:(NSData *) data {
    NSError * error;
    AVAudioPlayer*play = [[AVAudioPlayer alloc] initWithData:data error:&error];
    NSTimeInterval n = [play duration];
    NSString *timeStr = [NSString stringWithFormat:@"%.1f",n];

    return timeStr;
}
/**
 *  得到arm格式的Data
 */
+ (NSData*)encodeWAVEToAMROfData:(NSData*)cafData{
    NSData *data = EncodeWAVEToAMR(cafData, 1, 16);
    return data;
}

+ (NSData*)encodeWAVEToAMROfFile:(NSURL*)cafFileUrl{
    NSData *data = EncodeWAVEToAMR([NSData dataWithContentsOfURL:cafFileUrl], 1, 16);
    return data;
}

/**
 *  录制
 */
- (void)recordVioce {

    [_audioPlayer stop];
    _audioPlayer = nil;
    [self setupAudioRecorder];
    if (![_audioRecorder isRecording]) {
        [_audioRecorder record];//首次使用应用时如果调用record方法会询问用户是否允许使用麦克风
        self.timer.fireDate=[NSDate distantPast];
    }
}
/**
 *  停止录音
 */
- (NSURL*)stopVioce{
    
    [_audioRecorder stop];
    _audioRecorder = nil;
    self.timer.fireDate=[NSDate distantFuture];
    return tempFile;
}
/**
 *  销毁
 */
- (void)destroy{
   _audioRecorder = nil;
    [self.timer invalidate];
    self.timer = nil;
}

- (void)dealloc{
    [_audioPlayer stop];
    [_audioRecorder stop];
    _audioRecorder = nil;
    _audioPlayer = nil;
    [self.timer invalidate];
    self.timer = nil;
}

@end
