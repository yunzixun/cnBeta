//
//  NSDate+cnbeta.m
//  cnBeta
//
//  Created by hudy on 2017/1/14.
//  Copyright © 2017年 hudy. All rights reserved.
//

#import "NSDate+cnbeta.h"

@implementation NSDate (cnbeta)

- (NSDate *)plusOneDay;
{
    NSTimeInterval interval = (24*60*60);
    return [self dateByAddingTimeInterval:interval];
}

- (NSDate *)minusOneDay
{
    NSTimeInterval interval = -(24*60*60);
    return [self dateByAddingTimeInterval:interval];
}

+ (NSDate *)localeDate
{
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: [NSDate date]];
    return [[NSDate date] dateByAddingTimeInterval: interval];
}

@end
