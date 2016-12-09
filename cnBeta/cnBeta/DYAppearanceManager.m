//
//  DYAppearanceManager.m
//  cnBeta
//
//  Created by hudy on 16/8/26.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "DYAppearanceManager.h"
#import "DYSectionHeader.h"
#import "DYAppSettings.h"

@interface DYAppearanceManager ()

@property (nonatomic, strong)UIFont *CBFont;

@end

@implementation DYAppearanceManager

+ (instancetype)sharedManager
{
    static DYAppearanceManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DYAppearanceManager alloc]init];
    });
    return manager;

}

- (void)setup
{
    DYAppSettings *settings = [DYAppSettings sharedSettings];
    [[DYSectionHeader appearance] setBackgroundColor:[UIColor colorWithWhite:0.95 alpha:0.95]];
    if ([[UIDevice currentDevice] systemVersion].floatValue >= 8.0) {
        _CBFont = settings.thinFontEnabled ? [UIFont fontWithName:@".PingFang-SC-Light" size:15]:[UIFont systemFontOfSize:15];
    }else{
        _CBFont = [UIFont systemFontOfSize:15];
    }

}

- (void)updateCBFont
{
    DYAppSettings *settings = [DYAppSettings sharedSettings];
    _CBFont = settings.thinFontEnabled ? [UIFont fontWithName:@".PingFang-SC-Light" size:15]:[UIFont systemFontOfSize:15];
}

- (void)updateAppearance
{
    
}

@end
