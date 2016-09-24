//
//  NTESJSCrashReporter.h
//  Bugrpt
//
//  Created by Monkey on 16/1/21.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol NTESJSSupportProtocol <JSExport>

/**
 *    @brief JavaScript 上报异常接口
 *
 *    @param exp JS捕获到的exception
 */
-(void)reportJSException:(id) exception;

@end

@interface NTESJSCrashReporter : NSObject<NTESJSSupportProtocol>

+ (NTESJSCrashReporter *)sharedInstance;

/**
 *    @brief 初始化JS异常捕获
 *
 *    @param webview 需要捕获的UIWebView实例
 *    @param inject  是否自动注入脚本文件,以便获取更加详细的异常信息
 */
-(void)initJSCrashReporterWithWebView:(UIWebView *) webView injectScript:(BOOL) inject;

@end
