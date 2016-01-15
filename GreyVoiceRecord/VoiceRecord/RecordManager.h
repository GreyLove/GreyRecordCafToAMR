//
//  RecordManager.h
//  VoiceRecord
//
//  Created by 好价网络科技有限公司 on 16/1/15.
//  Copyright © 2016年 Grey. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^writeSuccessBlock)(BOOL success,NSData *amrData);
typedef void (^progressBlock)(float progress);

@interface RecordManager : NSObject

+(RecordManager*)shareManager;

@property (nonatomic,copy)progressBlock progress;

- (void)writeAuToAmrFile:(NSURL*)tmpFileUrl callback:(writeSuccessBlock)block;

- (void)startTalkVoice;

- (NSURL*)stopTalkVoice;

- (void)playAmrData:(NSData*)amrData;

- (NSString*)getAudioTime:(NSData *)data;

- (void)destroy;
@end
