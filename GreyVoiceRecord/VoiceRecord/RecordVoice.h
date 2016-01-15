//
//  RecordVoice.h
//  VoiceRecord
//
//  Created by 好价网络科技有限公司 on 15/12/25.
//  Copyright © 2015年 Grey. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^progressBlock)(float progress);

typedef void (^writeSuccessBlock)(BOOL success);


@interface RecordVoice : NSObject


@property (nonatomic,copy)progressBlock progress;

/* 录音 */
- (void)recordVioce;
- (NSURL*)stopVioce;
/* 获取时长 */
+ (NSString*) getAudioTime:(NSData *) data;

///* 得到amr data */
//+ (NSData*)encodeWAVEToAMROfData:(NSData*)cafData;
//+ (NSData*)encodeWAVEToAMROfFile:(NSURL*)cafFileUrl;

/* 播放amr类型字节 */
- (void)playCafData:(NSData*)data;
//- (void)writeToAmrFile:(NSURL*)tempFile0 amrData:(NSData*)curAudioData call:(writeSuccessBlock)block;



@end
