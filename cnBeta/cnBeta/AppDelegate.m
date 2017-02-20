//
//  AppDelegate.m
//  cnBeta
//
//  Created by hudy on 16/6/19.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "AppDelegate.h"
#import "AFNetworkActivityIndicatorManager.h"
//#import "UMSocial.h"
#import <UMSocialCore/UMSocialCore.h>
#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"
#import "CRToast.h"
#import "JPFPSStatus.h"
#import <Bugrpt/NTESCrashReporter.h>
#import "CBAppearanceManager.h"
#import "CBAppSettings.h"
#import "CBDataBase.h"
#import "CBObjectCache.h"
#import "CBCustomURLProtocol.h"
#import "CBHTTPURLProtocol.h"
#import "CBURLCache.h"
#import "UMMobClick/MobClick.h"

#import "NewsNavigationViewController.h"
#import "CBTabBarController.h"
#import "CBStackController.h"

@interface AppDelegate ()<UITabBarControllerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    [[CBAppearanceManager sharedManager] setup];
    
    [[CBDataBase sharedDataBase] prepareDataBase];

    
    [NSURLCache setSharedURLCache:[[CBURLCache alloc] init]];
    [NSURLProtocol registerClass:[CBHTTPURLProtocol class]];
    [NSURLProtocol registerClass:[CBCustomURLProtocol class]];
    
//#if defined(DEBUG)||defined(_DEBUG)
//    [[JPFPSStatus sharedInstance] open];
//#endif
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];//NavigationBar上控件title的颜色
    [[UISwitch appearance] setTintColor:globalColor];
    [[UISwitch appearance] setOnTintColor:globalColor];

    //监听网络状态
    [self listenNetWorkingPort];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    CBTabBarController *tabBarController = [mainStoryboard instantiateViewControllerWithIdentifier:@"CBTabBarController"];
    tabBarController.delegate = self;
    
    CBStackController *stackController = [[CBStackController alloc] initWithRootViewController:tabBarController];
    [self.window setRootViewController:stackController];
    [self.window setBackgroundColor:[UIColor whiteColor]];
    [self.window makeKeyAndVisible];
    
    
    UMConfigInstance.appKey = @"579b1ed4e0f55ab08c000e90";
    UMConfigInstance.channelId = @"App Store";
    [MobClick startWithConfigure:UMConfigInstance];
    [MobClick setCrashReportEnabled:NO];

    //打开调试日志
    [[UMSocialManager defaultManager] openLog:YES];
    
    //设置友盟appkey
    [[UMSocialManager defaultManager] setUmSocialAppkey:@"579b1ed4e0f55ab08c000e90"];
    //设置微信的appKey和appSecret
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:@"wx9006182f5fb2bb8a" appSecret:@"84ac7593b76c84ff04abaaa543d792b7" redirectURL:@"http://mobile.umeng.com/social"];
    
    
    //设置分享到QQ互联的appKey和appSecret
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:@"1105528200"  appSecret:@"9Av2cIJcSmVtgxoJ" redirectURL:@"http://mobile.umeng.com/social"];

    //设置新浪的appKey和appSecret
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina appKey:@"2324480522"  appSecret:@"57f4365b81dc68e5cb32ef6c16f31f37" redirectURL:@"http://mobile.umeng.com/social"];
    [[NTESCrashReporter sharedInstance] initWithAppId:@"I000174257"];
    
    //打印crash
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    return YES;
}

void uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
    // Internal error reporting
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
    if (result == FALSE) {
        //调用其他SDK，例如支付宝SDK等
    }
    return result;
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskPortrait;
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
        
        BOOL switchOn = [CBAppSettings sharedSettings].networkNotificationEnabled;
        
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
                              kCRToastAnimationInTypeKey : @(CRToastAnimationTypeLinear),
                              kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeLinear),
                              kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionLeft),
                              kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionRight)
                              };
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
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
    if ([CBAppSettings sharedSettings].autoClearEnabled) {
        [[CBObjectCache sharedCache] clearExpiredDiskCache];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[NSNotificationCenter defaultCenter] postNotificationName:CBNightModeTimeIntervalChangedNotification object:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[CBDataBase sharedDataBase] clearExpiredCache];
    if ([CBAppSettings sharedSettings].autoClearEnabled) {
        [[CBObjectCache sharedCache] clearExpiredDiskCache];
    }
}

@end
