//
//  SettingSwitchItem.h
//  cnBeta
//
//  Created by hudy on 16/8/8.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "SettingItem.h"

typedef NS_ENUM(NSInteger, SwitchName) {
    CBGesture,
    CBNetworkNotification,
    CBPrefetch,
    CBImageWiFiOnly,
    CBSourceDisplay,
    CBAutoCollection,
    CBFontChange,
    CBAutoClear
};

@interface SettingSwitchItem : SettingItem

@end
