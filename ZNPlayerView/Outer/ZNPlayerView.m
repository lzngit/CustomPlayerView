//
//  ZNPlayerView.m
//  ZNPlayerView
//
//  Created by lzn on 16/3/15.
//  Copyright © 2016年 go. All rights reserved.
//

#import "ZNPlayerView.h"
#import "ZNEventsProtocol.h"
#import "ZNPictureView.h"
#import "ZNOperationView.h"

@interface ZNPlayerView ()
//画面 view
@property(nonatomic,strong) ZNPictureView *picView;
//操作按钮 view
@property(nonatomic,strong) ZNOperationView *opView;
//传递事件
@property(nonatomic,nullable,strong) ZNEventsBlock eventsBlock;

@property(nonatomic,strong) NSString *recordPlayTime;
@property(nonatomic,strong) NSArray *recordOpViewState;
@end

@implementation ZNPlayerView

#pragma mark - Inner

- (void)operationViewQuitWith:(UIGestureRecognizer *)ges
{
    if (self.opView) {
        if (!ges) {
            self.recordPlayTime = nil;
        }else {
            self.recordOpViewState = self.opView.recordState;
        }
        ges.enabled = NO;
        [UIView animateWithDuration:0.4 animations:^{
            self.opView.transform = CGAffineTransformMakeTranslation(0, self.bounds.size.height);
        }completion:^(BOOL finished) {
            ges.enabled = YES;
            [self.picView removePlayProgressObserver];
            [self.opView removeFromSuperview];
            self.opView = nil;
        }];
    }
}
- (void)tapClicked:(UIGestureRecognizer *)ges
{
    if (!self.picView.prepareToPlay) {
        //画面好没准备好播放,则不执行手势
        return;
    }
    //增加同步锁和封锁手势都是为了避免可能发生的崩溃执行此方法时|[self.picView removeSliderObserver];|
    @synchronized(self)  {
        //没有操作 view 则创建弹出,有则动画让其退出
        if (!self.opView) {
            self.opView = [ZNOperationView createWithFrame:self.bounds];
            [self.opView changePlayBtnState:self.picView.nextPlayState];
            [self.opView changePlayBuffer:self.picView.currentBuffer];
            if (self.recordPlayTime) {
                [self.opView initStateWith:self.recordOpViewState];
            }
            [self addSubview:self.opView];
            self.opView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            self.opView.transform = CGAffineTransformMakeTranslation(0, self.bounds.size.height);
            [UIView animateWithDuration:0.2 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.opView.transform = CGAffineTransformIdentity;
            } completion:nil];
            self.opView.eventsBlock = self.eventsBlock;
            [self.picView addPlayProgressObserver];
        }else {
            [self operationViewQuitWith:ges];
        }
    }
}
- (void)initialization
{
    self.backgroundColor = [UIColor blackColor];
    self.clipsToBounds = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClicked:)];
    [self addGestureRecognizer:tap];
    
    __weak typeof(self) tmpSelf = self;
    self.eventsBlock = ^(__nullable id data, NSInteger type) {
        switch (type) {
            case ZNEventsPlayPatternType:
            {
                tmpSelf.picView.videoGravity = (NSString *)data;
            }
                break;
            case ZNEventsPlayPlayPauseType:
            {
                [tmpSelf.picView playOrPauseVideo:[(NSNumber *)data boolValue]];
            }
                break;
            case ZNEventsPlayFinishedType:
            {
                [tmpSelf operationViewQuitWith:nil];
            }
                break;
            case ZNEventsPlayProgressType:
            {
                tmpSelf.recordPlayTime = [tmpSelf.opView changePlayProgressWith:data];
            }
                break;
            case ZNEventsPlayBufferType:
            {
                [tmpSelf.opView changePlayBuffer:data];
            }
                break;
            case ZNEventsPlayControlProgressContinuous:
            {
                [tmpSelf.picView controlPlayProgressContinuous:[data floatValue]];
            }
                break;
            case ZNEventsPlayControlProgressGo:
            {
                [tmpSelf.picView controlPlayProgressGo:[data floatValue]];
            }
                break;
            default:
                break;
        }
    };
}
- (void)makeContentView
{
    //创建画面 view
    self.picView = [ZNPictureView createWithFrame:self.bounds];
    [self addSubview:self.picView];
    self.picView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.picView.backgroundColor = self.backgroundColor;
    self.picView.videoGravity = AVLayerVideoGravityResize;
    self.picView.eventsBlock = self.eventsBlock;
}

#pragma mark - Outer

- (instancetype)init
{
    self = [super init];
    if (self) {
        //|self|控件自身初始化参数配置
        [self initialization];
        //|self|控件要加载的内容 view
        [self makeContentView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //|self|控件自身初始化参数配置
        [self initialization];
        //|self|控件要加载的内容 view
        [self makeContentView];
    }
    return self;
}

//xib加载的方式入口
- (void)awakeFromNib
{
    //|self|控件自身初始化参数配置
    [self initialization];
    //|self|控件要加载的内容 view
    [self makeContentView];
}

- (void)setPlayUrl:(NSURL *)playUrl
{
    self.picView.playUrl = playUrl;
    [self operationViewQuitWith:nil];
}

- (NSURL *)playUrl
{
    return self.picView.playUrl;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    self.picView.backgroundColor = backgroundColor;
}




@end
