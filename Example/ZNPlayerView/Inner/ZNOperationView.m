//
//  ZNOperationView.m
//  ZNPlayerView
//
//  Created by lzn on 16/3/15.
//  Copyright © 2016年 go. All rights reserved.
//

#import "ZNOperationView.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "ZNTime.h"

@interface ZNOperationView ()
@property(nonatomic,strong) UIView *bottomView;
@property(nonatomic,strong) UIButton *btnPlay;
@property(nonnull,nonatomic,strong,readonly) UISlider *slider;
@property(nonnull,nonatomic,strong,readonly) UISlider *sliderProgress;
@property(nonnull,nonatomic,strong,readonly) UILabel *timeLbl;
@end

@implementation ZNOperationView

- (void)makeContentViewWithBounds:(CGRect)bounds
{
    NSDictionary *metrics = @{@"height":@44,@"width":@44,@"lblWidth":@120};
    UIView *bottomView = [[UINavigationBar alloc] init];
    //底部 view
    self.bottomView = bottomView;
    [self addSubview:self.bottomView];
    self.bottomView.translatesAutoresizingMaskIntoConstraints = NO;
    NSArray *consHorBottom = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bottomView]|" options:NSLayoutFormatDirectionLeftToRight metrics:nil views:NSDictionaryOfVariableBindings(bottomView)];
    [self addConstraints:consHorBottom];
    NSArray *consVorBottom =[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bottomView(height)]|" options:NSLayoutFormatDirectionLeftToRight metrics:metrics views:NSDictionaryOfVariableBindings(bottomView)];
    [self addConstraints:consVorBottom];
    
    UIButton * (^createBtnBlock)(NSString *)= ^(NSString * imgName) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
        btn.translatesAutoresizingMaskIntoConstraints = NO;
        [self.bottomView addSubview:btn];
        return btn;
    };
    //播放样式按钮
    UIButton *btnPlayPattern = createBtnBlock(@"playPattern");
    //播放按钮
    UIButton *btnPlay = createBtnBlock(@"player_play");
    [btnPlay setImage:[UIImage imageNamed:@"player_pause"] forState:UIControlStateSelected];
    self.btnPlay = btnPlay;
    
    NSArray *consHorBtnPattern = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[btnPlayPattern(width)]|" options:NSLayoutFormatDirectionLeftToRight metrics:metrics views:NSDictionaryOfVariableBindings(btnPlayPattern)];
    [self.bottomView addConstraints:consHorBtnPattern];
    NSArray *consVorBtnPattern = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[btnPlayPattern]|" options:NSLayoutFormatDirectionRightToLeft metrics:nil views:NSDictionaryOfVariableBindings(btnPlayPattern)];
    [self.bottomView addConstraints:consVorBtnPattern];
    
    NSArray *consHorBtnPlay = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[btnPlay(width)]" options:NSLayoutFormatDirectionLeftToRight metrics:metrics views:NSDictionaryOfVariableBindings(btnPlay)];
    [self.bottomView addConstraints:consHorBtnPlay];
    NSArray *consVorBtnPlay = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[btnPlay]|" options:NSLayoutFormatDirectionRightToLeft metrics:nil views:NSDictionaryOfVariableBindings(btnPlay)];
    [self.bottomView addConstraints:consVorBtnPlay];
    
    UISlider *slider = [[UISlider alloc] init];
    slider.minimumTrackTintColor = [UIColor redColor];
    slider.maximumTrackTintColor = [UIColor clearColor];
    _slider = slider;
    [self.bottomView addSubview:slider];
    
    UISlider *progress = [[UISlider alloc] initWithFrame:slider.bounds];
    _sliderProgress = progress;
    progress.userInteractionEnabled = NO;
    [progress setThumbImage:nil forState:UIControlStateNormal];
    [progress setThumbTintColor:[UIColor clearColor]];
    progress.minimumTrackTintColor = [UIColor magentaColor];
    self.sliderProgress.maximumTrackTintColor = [UIColor lightGrayColor];
    [slider addSubview:progress];
    [slider sendSubviewToBack:progress];
    progress.value = 1.0;
    
    progress.translatesAutoresizingMaskIntoConstraints = NO;
    slider.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSArray *consVorSlider = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[slider]|" options:NSLayoutFormatDirectionRightToLeft metrics:nil views:NSDictionaryOfVariableBindings(btnPlayPattern,slider,btnPlay)];
    [self.bottomView addConstraints:consVorSlider];
    
    NSLayoutConstraint *conLeftProgress = [NSLayoutConstraint constraintWithItem:progress attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:slider attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0];
    NSLayoutConstraint *conRightProgress = [NSLayoutConstraint constraintWithItem:progress attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:slider attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0];
    NSLayoutConstraint *conCenterY = [NSLayoutConstraint constraintWithItem:progress attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:slider attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
    [self.bottomView addConstraints:@[conLeftProgress,conRightProgress,conCenterY]];
    
    
    
    UILabel *timeLbl = [[UILabel alloc] init];
    _timeLbl = timeLbl;
    [self.bottomView addSubview:timeLbl];
    timeLbl.text = @"00:00 / 00:00";
    timeLbl.textAlignment = NSTextAlignmentCenter;
    timeLbl.textColor = [UIColor lightGrayColor];
    timeLbl.backgroundColor = [UIColor clearColor];
    timeLbl.translatesAutoresizingMaskIntoConstraints = NO;
    NSArray *consHorLbl = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[btnPlay][slider]-5-[timeLbl(>=lblWidth)][btnPlayPattern]" options:NSLayoutFormatDirectionLeftToRight metrics:metrics views:NSDictionaryOfVariableBindings(btnPlayPattern,slider,timeLbl,btnPlay)];
    [self.bottomView addConstraints:consHorLbl];
    NSArray *consVorLbl = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[timeLbl]|" options:NSLayoutFormatDirectionRightToLeft metrics:nil views:NSDictionaryOfVariableBindings(timeLbl)];
    [self.bottomView addConstraints:consVorLbl];
    
    
    [btnPlayPattern addTarget:self action:@selector(btnPlayPatternClicked) forControlEvents:UIControlEventTouchUpInside];
    [btnPlay addTarget:self action:@selector(btnPlayClicked:) forControlEvents:UIControlEventTouchUpInside];
    [slider addTarget:self action:@selector(controlPlayProgress:) forControlEvents:UIControlEventValueChanged];
    [slider addTarget:self action:@selector(controlPlayGo:) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *tapPrevent = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPrevent)];
    [self.bottomView addGestureRecognizer:tapPrevent];
}

- (void)tapPrevent{}

- (void)btnPlayPatternClicked
{
    static int i = 1;
    NSArray *array = @[AVLayerVideoGravityResize,AVLayerVideoGravityResizeAspect,AVLayerVideoGravityResizeAspectFill];
    self.eventsBlock(array[i%3],ZNEventsPlayPatternType);
    i++;
}

- (void)btnPlayClicked:(UIButton *)sender
{
    sender.selected = !sender.selected;
    self.eventsBlock(@(sender.selected),ZNEventsPlayPlayPauseType);
}

- (void)controlPlayProgress:(UISlider *)sender
{
    static BOOL beforeTracking = NO;
    if (beforeTracking && sender.tracking) {
        self.btnPlay.selected = NO;
        self.eventsBlock(@(sender.value),ZNEventsPlayControlProgressContinuous);
    }
    beforeTracking = sender.tracking;
}

- (void)controlPlayGo:(UISlider *)sender
{
    self.btnPlay.selected = YES;
    self.eventsBlock(@(sender.value),ZNEventsPlayControlProgressGo);
}


#pragma mark - Outer
+ (instancetype)createWithFrame:(CGRect)frame
{
    ZNOperationView *op = [[ZNOperationView alloc] init];
    op.frame = frame;
    op.backgroundColor = [UIColor clearColor];
    [op makeContentViewWithBounds:op.bounds];
    return op;
}

- (void)initStateWith:(NSArray *)stateArray
{
    self.timeLbl.text = stateArray[0];
    self.slider.value = [stateArray[1] floatValue];
}

- (void)changePlayBtnState:(BOOL)selected
{
    self.btnPlay.selected = selected;
}

- (NSString *)changePlayProgressWith:(NSArray *)timeArray
{
    float total = [timeArray.lastObject floatValue];
    float curent = [timeArray.firstObject floatValue];
    self.slider.value = curent/total;
    NSString *minutePlay = [ZNTime getMinuteFromSeconds:curent];
    NSString *minuteAll = [ZNTime getMinuteFromSeconds:total];
    self.timeLbl.text = [NSString stringWithFormat:@"%@ / %@",minutePlay,minuteAll];
    return self.timeLbl.text;
}

- (void)changePlayBuffer:(NSArray *)timeArray
{
    float total = [timeArray.lastObject floatValue];
    float curent = [timeArray.firstObject floatValue];
    self.sliderProgress.value = curent/total;
    if (self.sliderProgress.value == 1.0) {
        self.sliderProgress.maximumTrackTintColor = self.sliderProgress.minimumTrackTintColor;
    }else {
        self.sliderProgress.maximumTrackTintColor = [UIColor lightGrayColor];
    }
}

- (NSArray *)recordState
{
    return @[self.timeLbl.text,@(self.slider.value)];
}

@end
