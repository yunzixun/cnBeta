//
//  DYAppSettings.m
//  cnBeta
//
//  Created by hudy on 16/9/7.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "DYAppSettings.h"

static NSString *const gestureSwitchKey = @"gestureSwitch";
static NSString *const networkNotificationSwitchKey = @"networkNotoficationSwitch";

@interface DYAppSettings ()

@property (nonatomic, strong) NSUserDefaults* userDefaults;

@end

@implementation DYAppSettings

@synthesize gestureEnabled = _gestureEnabled;
@synthesize networkNotificationEnabled = _networkNotificationEnabled;

+ (instancetype)sharedSettings
{
    static DYAppSettings *settings = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        settings = [[DYAppSettings alloc]init];
    });
    return settings;
}

- (id)init
{
    self = [super init];
    if (self) {
        _userDefaults = [NSUserDefaults standardUserDefaults];
        
        [_userDefaults registerDefaults:@{gestureSwitchKey: @YES,
                                          networkNotificationSwitchKey: @YES
                                          }];
         _gestureEnabled= [_userDefaults boolForKey:gestureSwitchKey];
        _networkNotificationEnabled = [_userDefaults boolForKey:networkNotificationSwitchKey];
    }
    return self;
}

- (BOOL)gestureEnabled
{
    return _gestureEnabled;
}

- (void)setGestureEnabled:(BOOL)gestureEnabled
{
    _gestureEnabled = gestureEnabled;
    [_userDefaults setBool:gestureEnabled forKey:gestureSwitchKey];
}

- (BOOL)networkNotificationEnabled
{
    return _networkNotificationEnabled;
}

- (void)setNetworkNotificationEnabled:(BOOL)networkNotificationEnabled
{
    _networkNotificationEnabled = networkNotificationEnabled;
    [_userDefaults setBool:networkNotificationEnabled forKey:networkNotificationSwitchKey];
}











@end
