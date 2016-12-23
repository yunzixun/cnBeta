//
//  NTESCrashLogger.h
//  Bugrpt
//
//  Created by NetEase on 16/6/7.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NTESCrashLogger : NSObject

/**
 *    @brief  记录日志
 *
 *    @param logs 日志数据
 *
 */
+ (void) Log:(NSString *)logs, ...;

@end
