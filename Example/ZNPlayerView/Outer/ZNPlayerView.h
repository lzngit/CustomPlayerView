//
//  ZNPlayerView.h
//  ZNPlayerView
//
//  Created by lzn on 16/3/15.
//  Copyright © 2016年 go. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 *  视屏播放器 view
    1.支持 xib 创建
    2.支持屏幕自适应旋转
 */
@interface ZNPlayerView : UIView

/**
 *  赋值|playUrl|,即可自动播放视频
    不分是网络 url 和本地 url
 */
@property(nonatomic,nonnull,strong) NSURL *playUrl;

@end
