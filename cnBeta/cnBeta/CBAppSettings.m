//
//  DYAppSettings.m
//  cnBeta
//
//  Created by hudy on 16/9/7.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "CBAppSettings.h"

static NSString *const gestureSwitchKey = @"gestureSwitch";
static NSString *const networkNotificationSwitchKey = @"networkNotoficationSwitch";
static NSString *const prefetchSwitchKey = @"prefetchSwitch";
static NSString *const imageWiFiOnlySwitchKey = @"imageWiFiOnly";
static NSString *const sourceDisplaySwitchKey = @"sourceDisplaySwitch";
static NSString *const autoCollectionSwitchKey = @"autoCollectionSwitch";
static NSString *const thinFontSwitchKey = @"thinFontSwitch";
static NSString *const autoClearSwitchKey = @"autoClearSwitch";


@interface CBAppSettings ()

@property (nonatomic, strong) NSUserDefaults* userDefaults;

@end

@implementation CBAppSettings

@synthesize gestureEnabled = _gestureEnabled;
@synthesize networkNotificationEnabled = _networkNotificationEnabled;
@synthesize prefetchEnabled = _prefetchEnabled;
@synthesize imageWiFiOnlyEnabled = _imageWiFiOnlyEnabled;
@synthesize autoCollectionEnabled = _autoCollectionEnabled;
@synthesize thinFontEnabled  = _thinFontEnabled;
@synthesize sourceDisplayEnabled = _sourceDisplayEnabled;
@synthesize autoClearEnabled = _autoClearEnabled;

+ (instancetype)sharedSettings
{
    static CBAppSettings *settings = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        settings = [[CBAppSettings alloc]init];
    });
    return settings;
}

- (id)init
{
    self = [super init];
    if (self) {
        _userDefaults = [NSUserDefaults standardUserDefaults];
        
        [_userDefaults registerDefaults:@{gestureSwitchKey: @YES,
                                          networkNotificationSwitchKey: @NO,
                                          prefetchSwitchKey: @NO,
                                          imageWiFiOnlySwitchKey: @NO,
                                          sourceDisplaySwitchKey: @NO,
                                          autoCollectionSwitchKey:@YES,
                                          thinFontSwitchKey:@NO,
                                          autoClearSwitchKey:@NO
                                          }];
        _gestureEnabled= [_userDefaults boolForKey:gestureSwitchKey];
        _networkNotificationEnabled = [_userDefaults boolForKey:networkNotificationSwitchKey];
        _prefetchEnabled = [_userDefaults boolForKey:prefetchSwitchKey];
        _imageWiFiOnlyEnabled = [_userDefaults boolForKey:imageWiFiOnlySwitchKey];
        _sourceDisplayEnabled = [_userDefaults boolForKey:sourceDisplaySwitchKey];
        _autoCollectionEnabled = [_userDefaults boolForKey:autoCollectionSwitchKey];
        _thinFontEnabled = [_userDefaults boolForKey:thinFontSwitchKey];
        _autoClearEnabled = [_userDefaults boolForKey:autoClearSwitchKey];
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

- (BOOL)prefetchEnabled
{
    return _prefetchEnabled;
}

- (void)setPrefetchEnabled:(BOOL)prefetchEnabled
{
    _prefetchEnabled = prefetchEnabled;
    [_userDefaults setBool:prefetchEnabled forKey:prefetchSwitchKey];
}

- (BOOL)imageWiFiOnlyEnabled
{
    return _imageWiFiOnlyEnabled;
}

- (void)setImageWiFiOnlyEnabled:(BOOL)imageWiFiOnlyEnabled
{
    _imageWiFiOnlyEnabled = imageWiFiOnlyEnabled;
    [_userDefaults setBool:imageWiFiOnlyEnabled forKey:imageWiFiOnlySwitchKey];
}

- (BOOL)sourceDisplayEnabled
{
    return _sourceDisplayEnabled;
}

- (void)setSourceDisplayEnabled:(BOOL)sourceDisplayEnabled
{
    _sourceDisplayEnabled = sourceDisplayEnabled;
    [_userDefaults setBool:sourceDisplayEnabled forKey:sourceDisplaySwitchKey];
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

- (BOOL)autoClearEnabled
{
    return _autoClearEnabled;
}

- (void)setAutoClearEnabled:(BOOL)autoClearEnabled
{
    _autoClearEnabled = autoClearEnabled;
    [_userDefaults setBool:autoClearEnabled forKey:autoClearSwitchKey];
}







@end
