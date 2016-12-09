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
static NSString *const autoCollectionSwitchKey = @"autoCollectionSwitch";
static NSString *const thinFontSwitchKey = @"thinFontSwitch";

@interface DYAppSettings ()

@property (nonatomic, strong) NSUserDefaults* userDefaults;

@end

@implementation DYAppSettings

@synthesize gestureEnabled = _gestureEnabled;
@synthesize networkNotificationEnabled = _networkNotificationEnabled;
@synthesize autoCollectionEnabled = _autoCollectionEnabled;
@synthesize thinFontEnabled  = _thinFontEnabled;

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
                                          networkNotificationSwitchKey: @YES,
                                          autoCollectionSwitchKey:@YES,
                                          thinFontSwitchKey:@NO
                                          }];
        _gestureEnabled= [_userDefaults boolForKey:gestureSwitchKey];
        _networkNotificationEnabled = [_userDefaults boolForKey:networkNotificationSwitchKey];
        _autoCollectionEnabled = [_userDefaults boolForKey:autoCollectionSwitchKey];
        _thinFontEnabled = [_userDefaults boolForKey:thinFontSwitchKey];
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

- (BOOL)autoCollectionEnabled
{
    return _autoCollectionEnabled;
}

- (void)setAutoCollectionEnabled:(BOOL)autoCollectionEnabled
{
    _autoCollectionEnabled = autoCollectionEnabled;
    [_userDefaults setBool:autoCollectionEnabled forKey:autoCollectionSwitchKey];
}

-(BOOL)thinFontEnabled
{
    return _thinFontEnabled;
}

- (void)setThinFontEnabled:(BOOL)thinFontEnabled
{
    _thinFontEnabled = thinFontEnabled;
    [_userDefaults setBool:thinFontEnabled forKey:thinFontSwitchKey];
}









@end
