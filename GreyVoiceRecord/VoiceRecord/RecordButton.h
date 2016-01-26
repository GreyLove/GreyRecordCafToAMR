//
//  RecordButton.h
//  VoiceRecord
//
//  Created by 好价网络科技有限公司 on 15/12/25.
//  Copyright © 2015年 Grey. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^recordClick)();
typedef void(^stopClick)();
typedef void(^cancleClick)();

@interface RecordButton : UIButton

+(RecordButton *)createRecord:(CGRect)frame;



@property (nonatomic, copy) recordClick recordClickBlock;

@property (nonatomic, copy) stopClick stopClickBlock;

@property (nonatomic, copy) cancleClick cancleClickBlock;
@end
