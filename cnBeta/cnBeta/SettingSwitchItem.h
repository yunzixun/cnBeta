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
    CBAutoCollection,
    CBFontChange
};

@interface SettingSwitchItem : SettingItem

@end
