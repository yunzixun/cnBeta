//
//  DYAppSettings.h
//  cnBeta
//
//  Created by hudy on 16/9/7.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CBAppSettings : NSObject

@property (nonatomic) BOOL gestureEnabled;
@property (nonatomic) BOOL networkNotificationEnabled;
<<<<<<< HEAD:cnBeta/cnBeta/CBAppSettings.h
@property (nonatomic) BOOL prefetchEnabled;
@property (nonatomic) BOOL imageWiFiOnlyEnabled;
@property (nonatomic) BOOL sourceDisplayEnabled;
@property (nonatomic) BOOL autoCollectionEnabled;
@property (nonatomic) BOOL thinFontEnabled;
@property (nonatomic) BOOL autoClearEnabled;
=======
>>>>>>> parent of c5a4779... v1.3.3:cnBeta/cnBeta/DYAppSettings.h

+ (instancetype)sharedSettings;

@end
