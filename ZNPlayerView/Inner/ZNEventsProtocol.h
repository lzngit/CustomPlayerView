//
//  ZNEventsProtocol.h
//  ZNPlayerView
//
//  Created by lzn on 16/3/15.
//  Copyright © 2016年 go. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ZNEventsType) {
    ZNEventsPlayPatternType = 1, //播放画面模式
    ZNEventsPlayPlayPauseType,   //播放或暂停事件
    ZNEventsPlayFinishedType,    //播放完成事件
    ZNEventsPlayProgressType,    //播放进度事件,每隔1秒调用1次
    ZNEventsPlayBufferType,      //播放缓冲事件
    ZNEventsPlayControlProgressContinuous, //连续控制播放进度事件(停止播放)
    ZNEventsPlayControlProgressGo, //拖动后继续播放
};

typedef void(^ZNEventsBlock)(__nullable id data, NSInteger type);

@protocol ZNEventsProtocol <NSObject>
@property(nonatomic,nullable,strong) ZNEventsBlock eventsBlock;
@end
