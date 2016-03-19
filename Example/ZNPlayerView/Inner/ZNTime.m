//
//  ZNTime.m
//  ZNPlayerView
//
//  Created by lzn on 16/3/17.
//  Copyright © 2016年 go. All rights reserved.
//

#import "ZNTime.h"

@implementation ZNTime
+ (NSString *)getMinuteFromSeconds:(float)seconds
{
    seconds = roundf(seconds);
    int minute = seconds / 60;
    int s = (int)seconds % 60;
    NSString *minuteStr = nil;
    if (minute < 10) {
        minuteStr = [NSString stringWithFormat:@"0%d",minute];
    }else {
        minuteStr = [NSString stringWithFormat:@"%d",minute];
    }
    NSString *secondStr = nil;
    if (s < 10) {
        secondStr = [NSString stringWithFormat:@"0%d",s];
    }else {
        secondStr = [NSString stringWithFormat:@"%d",s];
    }
    NSString *time = [NSString stringWithFormat:@"%@:%@",minuteStr,secondStr];
    return time;
}
@end
