//
//  NSString+removehtml.m
//  cnBeta
//
//  Created by hudy on 2017/2/12.
//  Copyright © 2017年 hudy. All rights reserved.
//

#import "NSString+removehtml.h"

@implementation NSString (removehtml)

- (NSString *)removeHTML
{
    NSMutableString *string = [self mutableCopy];
    NSRange range1 = [string rangeOfString:@"<"];
    NSRange range2 = [string rangeOfString:@">"];
    if (range1.location < 100) {
        [string deleteCharactersInRange:NSMakeRange(range1.location, range2.location - range1.location +1)];
        return [string removeHTML];
    }
    return [string stringByReplacingOccurrencesOfString:@"\r\n" withString:@" "];
}

@end
