//
//  CBAppSettings.m
//  cnBeta
//
//  Created by hudy on 16/9/7.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "CBAppSettings.h"
#import "NSDate+cnbeta.h"

NSString *const CBAppSettingThemeChangedNotification = @"CBAppSettingThemeChangedNotification";
NSString *const CBAppSettingFontChangedNotification = @"CBAppSettingFontChangedNotification";
NSString *const CBNightModeTimeIntervalChangedNotification = @"CBNightModeTimeIntervalChangedNotification";
NSString *const CBPurchaseStateChangedNotification = @"CBPurchaseStateChangedNotification";
NSString *const CBPrefetchEnabledNotification = @"CBPrefetchEnabledNotification";


static NSString *const updateNotificationSwitchKey = @"updateNotificationSwitch";
static NSString *const networkNotificationSwitchKey = @"networkNotoficationSwitch";
static NSString *const prefetchSwitchKey = @"prefetchSwitch";
static NSString *const imageWiFiOnlySwitchKey = @"imageWiFiOnly";
static NSString *const sourceDisplaySwitchKey = @"sourceDisplaySwitch";
static NSString *const autoCollectionSwitchKey = @"autoCollectionSwitch";
static NSString *const thinFontSwitchKey = @"thinFontSwitch";
static NSString *const fullScreenSwitchKey = @"fullScreenSwitch";
static NSString *const nightModeSwitchKey = @"nightModeSwitch";
static NSString *const autoNightModeSwitchKey = @"autoNightModeSwitch";
static NSString *const autoClearSwitchKey = @"autoClearSwitch";
static NSString *const nightModeKey = @"nightMode";
static NSString *const purchasedKey = @"purchase";


@interface CBAppSettings ()

@property (nonatomic, strong) NSUserDefaults* userDefaults;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation CBAppSettings

@synthesize updateNotificationEnabled = _updateNotificationEnabled;
@synthesize networkNotificationEnabled = _networkNotificationEnabled;
@synthesize prefetchEnabled = _prefetchEnabled;
@synthesize imageWiFiOnlyEnabled = _imageWiFiOnlyEnabled;
@synthesize autoCollectionEnabled = _autoCollectionEnabled;
@synthesize thinFontEnabled  = _thinFontEnabled;
@synthesize sourceDisplayEnabled = _sourceDisplayEnabled;

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
        [_userDefaults registerDefaults:@{updateNotificationSwitchKey: @YES,
                                          networkNotificationSwitchKey: @NO,
                                          prefetchSwitchKey: @NO,
                                          imageWiFiOnlySwitchKey: @NO,
                                          sourceDisplaySwitchKey: @NO,
                                          autoCollectionSwitchKey:@YES,
                                          thinFontSwitchKey:@NO,
                                          fullScreenSwitchKey:@NO,
                                          nightModeSwitchKey:@NO,
                                          autoNightModeSwitchKey:@NO,
                                          autoClearSwitchKey:@NO,
                                          startTimeKey:@"00:00",
                                          endTimeKey:@"00:00",
                                          nightModeKey:@NO,
                                          purchasedKey:@NO
                                          }];
        _updateNotificationEnabled= [_userDefaults boolForKey:updateNotificationSwitchKey];
        _networkNotificationEnabled = [_userDefaults boolForKey:networkNotificationSwitchKey];
        _prefetchEnabled = [_userDefaults boolForKey:prefetchSwitchKey];
        _imageWiFiOnlyEnabled = [_userDefaults boolForKey:imageWiFiOnlySwitchKey];
        _sourceDisplayEnabled = [_userDefaults boolForKey:sourceDisplaySwitchKey];
        _autoCollectionEnabled = [_userDefaults boolForKey:autoCollectionSwitchKey];
        _thinFontEnabled = [_userDefaults boolForKey:thinFontSwitchKey];
        _fullScreenEnabled = [_userDefaults boolForKey:fullScreenSwitchKey];
        _nightModeEnabled = [_userDefaults boolForKey:nightModeSwitchKey];
        _autoNightModeEnabled = [_userDefaults boolForKey:autoNightModeSwitchKey];
        _autoClearEnabled = [_userDefaults boolForKey:autoClearSwitchKey];
        _nightMode = [_userDefaults boolForKey:nightModeKey];
        _purchased = [_userDefaults boolForKey:purchasedKey];
    }
    
    //[self configureNightMode];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(configureNightMode) name:CBNightModeTimeIntervalChangedNotification object:nil];
    return self;
}

- (NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        _dateFormatter.dateFormat = @"HH:mm";
    }
    return _dateFormatter;
}


- (void)configureNightMode
{
    if ([self.userDefaults boolForKey:autoNightModeSwitchKey]) {
        NSDate *startTime = [self.dateFormatter dateFromString:[self.userDefaults stringForKey:startTimeKey]];
        NSDate *endTime = [self.dateFormatter dateFromString:[self.userDefaults stringForKey:endTimeKey]];
        NSDate *nowTime = [self.dateFormatter dateFromString:[self.dateFormatter stringFromDate:[NSDate localeDate]]];
        
        if ([startTime compare:endTime] == NSOrderedSame) {
            if (self.nightMode) {
                self.nightMode = NO;
            }
            return;
        }
        
        if ([nowTime compare:endTime] == NSOrderedAscending) {
            if ([startTime compare: endTime] == NSOrderedDescending) {
                startTime = [startTime minusOneDay];
            }
        } else {
            if ([startTime compare: endTime] == NSOrderedAscending) {
                startTime = [startTime plusOneDay];
            }
            endTime = [endTime plusOneDay];
        }
        
        if ([startTime compare:nowTime] == NSOrderedAscending && [nowTime compare:endTime] == NSOrderedAscending) {
            if (!self.nightMode) {
                self.nightMode = YES;
            }
        }else {
            if (self.nightMode) {
                self.nightMode = NO;
            }
        }
        
        //设置夜间模式切换计时器
        if (self.timer) {
            [self.timer invalidate];
        }
        NSTimeInterval interval = 0;
        if (self.nightMode) {
            interval = [endTime timeIntervalSinceDate:nowTime];
        } else {
            interval = [startTime timeIntervalSinceDate:nowTime];
        }
        self.timer = [NSTimer scheduledTimerWithTimeInterval:interval repeats:NO block:^(NSTimer * _Nonnull timer) {
            self.nightMode = !self.nightMode;
        }];
        return;
    } else {
        if (self.timer) {
            [self.timer invalidate];
        }
    }
    if (self.nightMode == !self.nightModeEnabled) {
        self.nightMode = self.nightModeEnabled;
    }
    
}
- (BOOL)updateNotificationEnabled
{
    return _updateNotificationEnabled;
}

- (void)setUpdateNotificationEnabled:(BOOL)updateNotificationEnabled
{
    _updateNotificationEnabled = updateNotificationEnabled;
    [_userDefaults setBool:updateNotificationEnabled forKey:updateNotificationSwitchKey];
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
    if (prefetchEnabled) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CBPrefetchEnabledNotification object:nil];
    }
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
    [[NSNotificationCenter defaultCenter] postNotificationName:CBAppSettingFontChangedNotification object:nil];
}

- (void)setFullScreenEnabled:(BOOL)fullScreenEnabled
{
    _fullScreenEnabled = fullScreenEnabled;
    [_userDefaults setBool:fullScreenEnabled forKey:fullScreenSwitchKey];
}

- (void)setNightModeEnabled:(BOOL)nightModeEnabled
{
    _nightModeEnabled = nightModeEnabled;
    [_userDefaults setBool:nightModeEnabled forKey:nightModeSwitchKey];
    self.nightMode = nightModeEnabled;
}

- (void)setAutoNightModeEnabled:(BOOL)autoNightModeEnabled
{
    _autoNightModeEnabled = autoNightModeEnabled;
    [_userDefaults setBool:autoNightModeEnabled forKey:autoNightModeSwitchKey];
}


- (void)setAutoClearEnabled:(BOOL)autoClearEnabled
{
    _autoClearEnabled = autoClearEnabled;
    [_userDefaults setBool:autoClearEnabled forKey:autoClearSwitchKey];
}

- (void)setNightMode:(BOOL)nightMode
{
    _nightMode = nightMode;
    [_userDefaults setBool:nightMode forKey:nightModeKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:CBAppSettingThemeChangedNotification object:nil];
}

- (void)setPurchased:(BOOL)purchased
{
    if (!_purchased) {
        _purchased = purchased;
        [_userDefaults setBool:purchased forKey:purchasedKey];
        [[NSNotificationCenter defaultCenter] postNotificationName:CBPurchaseStateChangedNotification object:nil];
    }
}



@end
