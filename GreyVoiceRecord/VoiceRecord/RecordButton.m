//
//  RecordButton.m
//  VoiceRecord
//
//  Created by 好价网络科技有限公司 on 15/12/25.
//  Copyright © 2015年 Grey. All rights reserved.
//

#import "RecordButton.h"

@implementation RecordButton

+(RecordButton *)createRecord:(CGRect)frame{
    RecordButton *record = [RecordButton buttonWithType:UIButtonTypeCustom];
    if (!frame.size.width) {
        record.frame = CGRectMake(20, 30, 100, 60);
    }else{
        record.frame = frame;
    }

    [record setTitle:@"长按开始录音" forState:UIControlStateNormal];
    [record setTitle:@"正在录音..." forState:UIControlStateHighlighted];
    [record setBackgroundColor:[UIColor brownColor]];
    record.titleLabel.font = [UIFont systemFontOfSize:15];
    [record setTitleColor:[UIColor yellowColor] forState:UIControlStateHighlighted];
    
    [record addTarget:record action:@selector(recordButtonTouchDown) forControlEvents:UIControlEventTouchDown];
    [record addTarget:record action:@selector(recordButtonTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
    [record addTarget:record action:@selector(recordButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [record addTarget:record action:@selector(recordDragOutside) forControlEvents:UIControlEventTouchDragExit];
    [record addTarget:record action:@selector(recordDragInside) forControlEvents:UIControlEventTouchDragEnter];
    return record;
    
}
- (void)recordButtonTouchDown{
//    NSLog(@"UIControlEventTouchDown");
//    [self recordClick];
    [self record];
}
- (void)recordButtonTouchUpOutside{
//    NSLog(@"UIControlEventTouchUpOutside");
    //    [self stopClick];
    [self stop];
 }
- (void)recordButtonTouchUpInside{
//    NSLog(@"UIControlEventTouchUpInside");
    //    [self stopClick];
    [self stop];
}
- (void)recordDragOutside{
//    NSLog(@"UIControlEventTouchDragExit");
    //    [self pauseClick];
    [self stop];
}
- (void)recordDragInside{
//    NSLog(@"UIControlEventTouchDragEnter");
    //    [self resumeClick];
    [self stop];
}
- (void)record{
    if (_recordClickBlock) {
        _recordClickBlock();
    }
}
- (void)stop{
    if (_stopClickBlock) {
        _stopClickBlock();
    }
}
@end
