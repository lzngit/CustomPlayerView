//
//  ZNOperationView.h
//  ZNPlayerView
//
//  Created by lzn on 16/3/15.
//  Copyright © 2016年 go. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZNEventsProtocol.h"

@interface ZNOperationView : UIView <ZNEventsProtocol>
/**
 *  在此控件消失退出时,返回最后时刻的状态
 */
@property(nonatomic,nullable,strong) NSArray *recordState;

@property(nonatomic,nullable,strong) ZNEventsBlock eventsBlock;

+ (nonnull instancetype)createWithFrame:(CGRect)frame;

/**
 *  需要判断是否需要初始化,如果换了新的播放地址,则无需调用次方法
 *
 *  @param stateArray |recordState|
 */
- (void)initStateWith:(nonnull NSArray *)stateArray;

- (void)changePlayBtnState:(BOOL)selected;
- (nullable NSString *)changePlayProgressWith:(nonnull NSArray *)timeArray;
-(void)changePlayBuffer:(nonnull NSArray *)timeArray;
@end
