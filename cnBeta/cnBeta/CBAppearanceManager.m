//
//  DYAppearanceManager.m
//  cnBeta
//
//  Created by hudy on 16/8/26.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "CBAppearanceManager.h"
#import "DYSectionHeader.h"
#import "CBAppSettings.h"

<<<<<<< HEAD:cnBeta/cnBeta/CBAppearanceManager.m
@interface CBAppearanceManager ()

@property (nonatomic, strong)UIFont *CBFont;

@end

@implementation CBAppearanceManager
=======
@implementation DYAppearanceManager
>>>>>>> parent of c5a4779... v1.3.3:cnBeta/cnBeta/DYAppearanceManager.m

+ (instancetype)sharedManager
{
    static CBAppearanceManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[CBAppearanceManager alloc]init];
    });
    return manager;

}

- (void)setup
{
<<<<<<< HEAD:cnBeta/cnBeta/CBAppearanceManager.m
    CBAppSettings *settings = [CBAppSettings sharedSettings];
    [[DYSectionHeader appearance] setBackgroundColor:[UIColor colorWithWhite:0.95 alpha:0.95]];
    if ([[UIDevice currentDevice] systemVersion].floatValue >= 8.0) {
        _CBFont = settings.thinFontEnabled ? [UIFont fontWithName:@".PingFang-SC-Light" size:15]:[UIFont systemFontOfSize:15];
    }else{
        _CBFont = [UIFont systemFontOfSize:15];
    }

}

- (void)updateCBFont
{
    CBAppSettings *settings = [CBAppSettings sharedSettings];
    _CBFont = settings.thinFontEnabled ? [UIFont fontWithName:@".PingFang-SC-Light" size:15]:[UIFont systemFontOfSize:15];
=======
    [DYAppSettings sharedSettings];
    [[DYSectionHeader appearance] setBackgroundColor:[UIColor colorWithWhite:0.95 alpha:0.95]];
>>>>>>> parent of c5a4779... v1.3.3:cnBeta/cnBeta/DYAppearanceManager.m
}

- (void)updateAppearance
{
    
}

@end
