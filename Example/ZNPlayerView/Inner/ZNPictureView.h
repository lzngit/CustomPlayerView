//
//  ZNPictureView.h
//  ZNPlayerView
//
//  Created by lzn on 16/3/15.
//  Copyright © 2016年 go. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ZNEventsProtocol.h"

@interface ZNPictureView : UIView <ZNEventsProtocol>
@property(nonatomic,nonnull,strong) NSURL *playUrl;
@property(nonatomic,nonnull,strong) NSString *videoGravity;
@property(nonatomic,nullable,strong) ZNEventsBlock eventsBlock;
@property(nonatomic,nonnull,strong,readonly) NSArray *currentBuffer;
/**
 *  是否准备好播放
 */
@property(nonatomic,assign,readonly) BOOL prepareToPlay;

/**
 *  播放按钮的状态
 */
@property(nonatomic,assign,readonly) BOOL nextPlayState;

+ (nonnull instancetype)createWithFrame:(CGRect)frame;

//成对使用
- (void)addPlayProgressObserver;
- (void)removePlayProgressObserver;

- (void)playOrPauseVideo:(BOOL)state;

- (void)controlPlayProgressContinuous:(float)value;
- (void)controlPlayProgressGo:(float)value;
@end
