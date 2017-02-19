//
//  CBAppSettings.h
//  cnBeta
//
//  Created by hudy on 16/9/7.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const CBAppSettingThemeChangedNotification;
extern NSString *const CBAppSettingFontChangedNotification;
extern NSString *const CBNightModeTimeIntervalChangedNotification;
extern NSString *const CBPurchaseStateChangedNotification;
extern NSString *const CBPrefetchEnabledNotification;


@interface CBAppSettings : NSObject

@property (nonatomic) BOOL updateNotificationEnabled;
@property (nonatomic) BOOL networkNotificationEnabled;
@property (nonatomic) BOOL prefetchEnabled;
@property (nonatomic) BOOL imageWiFiOnlyEnabled;
@property (nonatomic) BOOL sourceDisplayEnabled;
@property (nonatomic) BOOL autoCollectionEnabled;
@property (nonatomic) BOOL thinFontEnabled;
@property (nonatomic) BOOL fullScreenEnabled;
@property (nonatomic) BOOL nightModeEnabled;
@property (nonatomic) BOOL autoNightModeEnabled;
@property (nonatomic) BOOL autoClearEnabled;

@property (nonatomic, getter=isNightMode) BOOL nightMode;
@property (nonatomic, getter=isPurchased) BOOL purchased;

+ (instancetype)sharedSettings;

@end
