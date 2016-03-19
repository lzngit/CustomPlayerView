//
//  ZNPictureView.m
//  ZNPlayerView
//
//  Created by lzn on 16/3/15.
//  Copyright © 2016年 go. All rights reserved.
//

#import "ZNPictureView.h"
#import "ZNTime.h"

@interface ZNPictureView ()
{
    __block CGFloat _recordBeforeValue;
}
@property(nonatomic,strong) AVPlayer *player;
@property(nonatomic,strong) id playbackObserver;
@property(nonatomic,strong) UIActivityIndicatorView *actView;
@property(nonatomic,strong) UIButton *centerPlayBtn;
@property(nonatomic,strong) NSURL *playFinishUrl;
@end

@implementation ZNPictureView

+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

- (void)dealloc
{
    [self playOrPauseVideo:NO];
    [self removeNotification];
    [self removeObserverFromPlayerItem:self.player.currentItem];
}

#pragma mark - Inner
- (void)centerPlayBtnClicked
{
    self.playUrl = self.playFinishUrl;

}
- (UIButton *)centerPlayBtn
{
    if (!_centerPlayBtn) {
        _centerPlayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_centerPlayBtn setImage:[UIImage imageNamed:@"player_play"] forState:UIControlStateNormal];
        [_centerPlayBtn addTarget:self action:@selector(centerPlayBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _centerPlayBtn;
}
/**
 *  添加播放器通知
 */
-(void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

-(void)removeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 *  播放完成通知
 *
 *  @param notification 通知对象
 */
-(void)playbackFinished:(NSNotification *)notification
{
    self.eventsBlock(nil,ZNEventsPlayFinishedType);
    self.playFinishUrl = self.playUrl;
    [self addSubview:self.centerPlayBtn];
    _centerPlayBtn.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *conHorCenter = [NSLayoutConstraint constraintWithItem:_centerPlayBtn attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
    NSLayoutConstraint *conVorCenter = [NSLayoutConstraint constraintWithItem:_centerPlayBtn attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
    [self addConstraints:@[conHorCenter,conVorCenter]];
}

- (void)addPlayProgressObserver
{
    AVPlayerItem *playerItem = self.player.currentItem;
    float total = CMTimeGetSeconds([playerItem duration]);
    __weak typeof(self) tmpSel = self;
    //这里设置每秒执行一次
    self.playbackObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        float current = CMTimeGetSeconds(time);
        if (tmpSel.eventsBlock) {
            tmpSel.eventsBlock(@[@(current),@(total)],ZNEventsPlayProgressType);
        }
    
    }];
}

- (void)removePlayProgressObserver
{
    [self.player removeTimeObserver:self.playbackObserver];
    self.playbackObserver = nil;
}
/**
 *  给AVPlayerItem添加监控
 *
 *  @param playerItem AVPlayerItem对象
 */
-(void)addObserverToPlayerItem:(AVPlayerItem *)playerItem{
    //监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //监控网络加载情况属性
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
}
-(void)removeObserverFromPlayerItem:(AVPlayerItem *)playerItem{
    [playerItem removeObserver:self forKeyPath:@"status"];
    [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
}
/**
 *  通过KVO监控播放器状态
 *
 *  @param keyPath 监控属性
 *  @param object  监视器
 *  @param change  状态改变
 *  @param context 上下文
 */
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    [self.actView stopAnimating];

    AVPlayerItem *playerItem = object;
    float total = CMTimeGetSeconds([playerItem duration]);
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status = [[change objectForKey:@"new"] intValue];
        if(status == AVPlayerStatusReadyToPlay){
        }else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"视频加载失败,请检查下地址或网络" delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles: nil];
            [alert show];
            [self playbackFinished:nil];
        }
    }else if([keyPath isEqualToString:@"loadedTimeRanges"]){
        NSArray *array = playerItem.loadedTimeRanges;
        //本次缓冲时间范围
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        //缓冲总长度
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;
        if (self.eventsBlock) {
            self.eventsBlock(@[@(totalBuffer),@(total)],ZNEventsPlayBufferType);
        }
    }
}


- (void)makeContentViewWithBounds:(CGRect)bounds
{
    [self addNotification];

    //创建菊花旋转 view
    self.actView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.actView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.actView];
    
    NSLayoutConstraint *conHorCenter = [NSLayoutConstraint constraintWithItem:self.actView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
    NSLayoutConstraint *conVorCenter = [NSLayoutConstraint constraintWithItem:self.actView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
    [self addConstraints:@[conHorCenter,conVorCenter]];
}

#pragma mark - Outer
+ (instancetype)createWithFrame:(CGRect)frame
{
    ZNPictureView *pic = [[ZNPictureView alloc] init];
    pic.frame = frame;
    [pic makeContentViewWithBounds:pic.bounds];
    return pic;
}

- (void)setPlayUrl:(NSURL *)playUrl
{
    //先清除之前所有的状态
    if (self.player) {
        [self removeObserverFromPlayerItem:self.player.currentItem];
        if (self.player.rate) {
            [self.player pause];
        }
        self.playFinishUrl = nil;
        if (_centerPlayBtn) {
            [_centerPlayBtn removeFromSuperview];
            _centerPlayBtn = nil;
        }
    }

    
    _playUrl = playUrl;

    AVPlayerItem *newItem = [AVPlayerItem playerItemWithURL:_playUrl];
    [self addObserverToPlayerItem:newItem];
    
    if (!self.player) {
        self.player = [AVPlayer playerWithPlayerItem:newItem];
        ((AVPlayerLayer *)self.layer).player = self.player;
    }else {
        [self.player replaceCurrentItemWithPlayerItem:newItem];
    }

    [self.actView startAnimating];
    [self playOrPauseVideo:YES];
}

- (void)setVideoGravity:(NSString *)videoGravity
{
    _videoGravity = videoGravity;
    ((AVPlayerLayer *)self.layer).videoGravity = _videoGravity;
}

- (BOOL)prepareToPlay
{
    return (self.player.status == AVPlayerStatusReadyToPlay ? YES : NO)&&_centerPlayBtn == nil;
}

- (void)playOrPauseVideo:(BOOL)state
{
    if (state) {
        [self.player play];
    }else {
        [self.player pause];
    }
}

- (BOOL)nextPlayState
{
    return self.player.rate == 0.0 ? NO : YES;
}

- (NSArray *)currentBuffer
{
    
    float total = CMTimeGetSeconds(self.player.currentItem.duration);
    NSArray *array = self.player.currentItem.loadedTimeRanges;
    //本次缓冲时间范围
    CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    //缓冲总长度
    NSTimeInterval totalBuffer = startSeconds + durationSeconds;
    float current = totalBuffer;
    return @[@(current),@(total)];
}

- (void)controlPlayProgressContinuous:(float)value
{
    if (self.player.rate) {
        [self.player pause];
    }
    
    AVPlayerItem *item = self.player.currentItem;
    float total = CMTimeGetSeconds(item.duration);
    if (![self.actView isAnimating]) {
        [self.actView startAnimating];
    }
    [self.player seekToTime:CMTimeMake(total*value, 1.0) completionHandler:^(BOOL finished) {
    }];
}

- (void)controlPlayProgressGo:(float)value
{

    if ([self.actView isAnimating]) {
        [self.actView stopAnimating];
    }
    if (self.prepareToPlay) {
        [self.player play];
    }
}

@end
