//
//  RecordManager.m
//  VoiceRecord
//
//  Created by 好价网络科技有限公司 on 16/1/15.
//  Copyright © 2016年 Grey. All rights reserved.
//

#import "RecordManager.h"
#import "RecordVoice.h"
#import "amrFileCodec.h"
static RecordManager *signle = nil;
@implementation RecordManager
{
    RecordVoice *recordVoice;
    BOOL isRecording;
}
+(RecordManager*)shareManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        signle = [[self alloc] init];
    });
    return signle;
}

- (id)init{
    if (self = [super init]) {
        __weak __typeof(self) weakSelf = self;
        recordVoice = [[RecordVoice alloc] init];
        recordVoice.progress = ^(float progress){
            [weakSelf refreshProgress:progress];
        };

    }
    return self;
}

- (void)refreshProgress:(float)progress{
    if (_progress) {
        _progress(progress);
    }
}

- (void)startTalkVoice:(NSString*)fileName{
    [recordVoice recordVioce:fileName];
}

- (NSURL*)stopTalkVoice{
     NSURL *fileUrl = [recordVoice stopVioce];
    return fileUrl;
}

- (void)playAmrData:(NSData*)amrData{

    if ([amrData isKindOfClass:[NSData class]]) {
        [recordVoice playCafData:DecodeAMRToWAVE(amrData)];
    }
}
- (NSString*)getAudioTime:(NSData *)data{
    
    return [recordVoice getAudioTime:data];
}
/**
 *  得到arm格式的Data
 */
- (NSData*)encodeWAVEToAMROfData:(NSData*)cafData{
    NSData *data = EncodeWAVEToAMR(cafData, 1, 16);
    return data;
}

- (NSData*)encodeWAVEToAMROfFile:(NSURL*)cafFileUrl{
    NSData *data = EncodeWAVEToAMR([NSData dataWithContentsOfURL:cafFileUrl], 1, 16);
    return data;
}

/**
 *  写入文件
 */
- (void)writeAuToAmrFile:(NSURL*)tmpFileUrl callback:(writeSuccessBlock)block{
    if ([tmpFileUrl isKindOfClass:[NSURL class]]) {
        NSData *amrData = [self encodeWAVEToAMROfFile:tmpFileUrl];
        [self writeToAmrFile:tmpFileUrl amrData:amrData call:block];
    }
}

- (void)writeToAmrFile:(NSURL*)tempFile0 amrData:(NSData*)curAudioData call:(writeSuccessBlock)block{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [paths objectAtIndex:0];
    NSString *amrName = [[[tempFile0 lastPathComponent] componentsSeparatedByString:@"."] firstObject];
    NSString *amrFile = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.amr",amrName]];
    BOOL ist = [curAudioData writeToFile:amrFile atomically:YES];
    if (block) {
        block(ist,curAudioData);
    }

}
- (void)destroy{
    [recordVoice destroy];
}
@end
