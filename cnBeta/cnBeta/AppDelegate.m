//
//  AppDelegate.m
//  cnBeta
//
//  Created by hudy on 16/6/19.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "AppDelegate.h"
#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"
//#import "UMSocial.h"
#import <UMSocialCore/UMSocialCore.h>
#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"
#import "CRToast.h"
#import "JPFPSStatus.h"
#import <Bugrpt/NTESCrashReporter.h>
#import "DYAppearanceManager.h"
#import "DYAppSettings.h"
#import "DataBase.h"
#import "CBDataBase.h"
#import "UMMobClick/MobClick.h"

#import "NewsNavigationViewController.h"

@interface AppDelegate ()<UITabBarControllerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    [[DYAppearanceManager sharedManager] setup];
    
    [[DataBase sharedDataBase] createDataBase];
    [[CBDataBase sharedDataBase] prepareDataBase];
    
//#if defined(DEBUG)||defined(_DEBUG)
//    [[JPFPSStatus sharedInstance] open];
//#endif
    
    //监听网络状态
    [self listenNetWorkingPort];
    
    // Override point for customization after application launch.
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:50/255.0 green:100/255.0 blue:200/255.0 alpha:1.0]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UITabBar appearance] setTranslucent:NO];
    [[UITabBar appearance] setBarTintColor:[UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0]];

    //获取tabBarController
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    tabBarController.delegate = self;
    
    
    UMConfigInstance.appKey = @"579b1ed4e0f55ab08c000e90";
    UMConfigInstance.channelId = @"App Store";
    //UMConfigInstance.eSType = E_UM_GAME; //仅适用于游戏场景，应用统计不用设置
    [MobClick startWithConfigure:UMConfigInstance];
    
//    //设置友盟社会化组件appkey
//    [UMSocialData setAppKey:@"579b1ed4e0f55ab08c000e90"];
//    //设置微信AppId、appSecret，分享url
//    [UMSocialWechatHandler setWXAppId:@"wx9006182f5fb2bb8a" appSecret:@"84ac7593b76c84ff04abaaa543d792b7" url:@"http://www.umeng.com/social"];
//    //设置手机QQ 的AppId，Appkey，和分享URL，需要#import "UMSocialQQHandler.h"
//    [UMSocialQQHandler setQQWithAppId:@"1105528200" appKey:@"9Av2cIJcSmVtgxoJ" url:@"http://www.umeng.com/social"];
    //打开调试日志
    [[UMSocialManager defaultManager] openLog:YES];
    
    //设置友盟appkey
    [[UMSocialManager defaultManager] setUmSocialAppkey:@"579b1ed4e0f55ab08c000e90"];
    //设置微信的appKey和appSecret
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:@"wx9006182f5fb2bb8a" appSecret:@"84ac7593b76c84ff04abaaa543d792b7" redirectURL:@"http://mobile.umeng.com/social"];
    
    
    //设置分享到QQ互联的appKey和appSecret
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:@"1105528200"  appSecret:@"9Av2cIJcSmVtgxoJ" redirectURL:@"http://mobile.umeng.com/social"];

    
    [[NTESCrashReporter sharedInstance] initWithAppId:@"I000174257"];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
    if (result == FALSE) {
        //调用其他SDK，例如支付宝SDK等
    }
    return result;
}

-(void)listenNetWorkingPort
{
    //创建网络监听管理者对象
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    
    /*
     typedef NS_ENUM(NSInteger, AFNetworkReachabilityStatus) {
     AFNetworkReachabilityStatusUnknown          = -1,//未识别的网络
     AFNetworkReachabilityStatusNotReachable     = 0,//不可达的网络(未连接)
     AFNetworkReachabilityStatusReachableViaWWAN = 1,//2G,3G,4G...
     AFNetworkReachabilityStatusReachableViaWiFi = 2,//wifi网络
     };
     */
    //设置监听
    
    __block BOOL count = NO;
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        BOOL switchOn = [DYAppSettings sharedSettings].networkNotificationEnabled;
        
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"未识别的网络");
                break;
                
            case AFNetworkReachabilityStatusNotReachable:
                if (switchOn && count) {
                    [self showNotificationWithText:@"网络连接已断开"];
                    
                }
                NSLog(@"不可达的网络(未连接)");
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN:
                if (switchOn && count) {
                    [self showNotificationWithText:@"网络连接已切换至蜂窝网络"];
                    
                }
                NSLog(@"2G,3G,4G...的网络");
                break;
                
            case AFNetworkReachabilityStatusReachableViaWiFi:
                if (switchOn && count) {
                    [self showNotificationWithText:@"网络连接已切换至无线网络"];
                    
                }
                NSLog(@"wifi的网络");
                break;
            default:
                break;
                
                
        }
        count = YES;
    }];
    //开始监听
    [manager startMonitoring];
}

- (void)showNotificationWithText:(NSString *)text
{
    NSDictionary *options = @{
                              kCRToastTextKey : text,
                              kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                              kCRToastBackgroundColorKey : [UIColor redColor],
                              kCRToastKeepNavigationBarBorderKey : @(CRToastTypeNavigationBar),
                              kCRToastAnimationInTypeKey : @(CRToastAnimationTypeGravity),
                              kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeGravity),
                              kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionLeft),
                              kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionRight)
                              };
    [CRToastManager showNotificationWithOptions:options
                                completionBlock:^{
                                    NSLog(@"Completed");
                                }];
}

#pragma mark - UITabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    //NSLog(@"%@", viewController);
//    if ([viewController isKindOfClass: [NewsNavigationViewController class]]) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"TabRefresh" object:nil userInfo:nil];
//    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TabRefresh" object:nil userInfo:nil];
}




- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[CBDataBase sharedDataBase] clearExpiredCache];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[CBDataBase sharedDataBase] clearExpiredCache];
}

@end
