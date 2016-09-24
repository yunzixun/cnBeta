//
//  bugrpt.h
//  bugrpt
//
//  Created by Monkey on 15/3/31.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <UIKit/UIKit.h>

@protocol NTESCrashReporterDelegate <NSObject>

@optional
/**
 *    @brief 异常回调接口，这个接口尽量避免使用复杂的代码
 *
 *    @param exception 异常
 */
- (NSString *) attachmentForException:(NSException *)exception;

@end

@interface NTESCrashReporter : NSObject

+ (NTESCrashReporter *)sharedInstance;

#pragma mark 以下函数请在调用初始化接口前设置

/**
 *    @brief 设置异常回调代理
 *
 *    @param delegate 代理
 */
- (void)setBugrptDelegate:(id<NTESCrashReporterDelegate>) delegate;

/**
 *    @brief  设置渠道标识, 默认为空值
 *
 *    如需修改设置, 请在初始化方法之前调用设置
 *
 *    @param channel 渠道名称
 */
- (void)setChannel:(NSString *)channel;

/**
 *    @brief 是否开启sdk日志打印, 默认为No, 不打印
 *
 *    @param enabled
 */
- (void)enableLog:(BOOL)enabled;

#pragma mark sdk初始化

/*
 *    @brief   iOS崩溃收集初始化接口(建议使用该接口)
 *
 *    @pagram  appId  在Bugrpt的页面注册产品时生成的应用标识
 */
- (BOOL)initWithAppId:(NSString*) appId;

/**
 *    @brief  初始化SDK接口并启动崩溃捕获上报功能, 如果你的App包含Application Extension或App Watch扩展，采用此方法初始化
 *
 *    @param appId 在Bugrpt的页面注册产品时生成的应用标识
 *    @param identifier AppGroup标识, 开启App-Groups功能时, 定义的Identifier
 *
 *    @return
 */
- (BOOL)initWithAppId:(NSString *)appId applicationGroupIdentifier:(NSString *)identifier;

/*
 *    @brief   iOS崩溃收集初始化接口
 *
 *    @pagram  appId  在Bugrpt的页面注册产品时生成的应用标识
 *
 *    @pagram  customParams, 产品需要传递的自定义参数, 不传默认为空
 */
- (BOOL)iosCrashInitWithAppId:(NSString*) appId customParams:(NSString *)customParams;

/*
 *    @brief  主动上报用户自定义的异常，比如自定义日志
 *
 *    @param type         类别
 *    @param content      内容
 */
-(void)uploadCustomizedException:(NSString*)type value:(NSString*)content;

/**
 *    @brief 自定义参数
 *
 *    @param key
 *    @param value
 */
- (void) setUserParams:(NSString *)key value:(NSString *)value;

#pragma mark 用于模拟异常测试
/**
 *    @brief  触发一个OC的异常
 */
- (void)triggerNSException;

/**
 *    @brief  触发一个错误信号
 */
- (void)triggerSignalError;

#pragma mark 内部调用

/*
 *    @brief  使用测试服务器地址设为YES，默认使用正式服务器为NO(内部调用函数)
 */
-(void)setUseTestAddr:(BOOL) useTestAddr;

/*
 *    @brief  发送Lua层的dump信息(内部调用函数)
 */
+ (void)sendLuaReportsToServer:(NSDictionary*) args;

/*
 *    @brief  上报自定义异常(内部调用函数)
 *    
 *    @param category     类别
 *    @param name         异常名
 *    @param reason       异常原因
 *    @param callStack    异常堆栈
 *    @param infoDic      附加数据
 *    @param terminate    是否终止app
 */
- (void)reportException:(NSUInteger) category name:(NSString *) name reason:(NSString *) reason callStack:(NSString *) callStack extraInfo:(NSDictionary *) infoDic terminateApp:(BOOL) terminate;

@end


