//
//  DYAppSettings.h
//  cnBeta
//
//  Created by hudy on 16/9/7.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DYAppSettings : NSObject

@property (nonatomic) BOOL gestureEnabled;
@property (nonatomic) BOOL networkNotificationEnabled;
@property (nonatomic) BOOL autoCollectionEnabled;
@property (nonatomic) BOOL thinFontEnabled;

+ (instancetype)sharedSettings;

@end
