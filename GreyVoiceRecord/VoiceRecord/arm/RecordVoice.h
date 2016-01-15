//
//  RecordVoice.h
//  VoiceRecord
//
//  Created by 好价网络科技有限公司 on 15/12/25.
//  Copyright © 2015年 Grey. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^progressBlock)(float progress);



@interface RecordVoice : NSObject


@property (nonatomic,copy)progressBlock progress;

/* 录音 uid文件名_时间戳*/
- (void)recordVioce:(NSString*)uid;
- (NSURL*)stopVioce;

/* 获取时长 */
- (NSString*)getAudioTime:(NSData *) data;

/* 播放caf类型字节 */
- (void)playCafData:(NSData*)data;

/* 销毁对象 */
- (void)destroy;

@end
