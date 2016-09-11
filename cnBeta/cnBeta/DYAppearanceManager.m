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
    [DYAppSettings sharedSettings];
    [[DYSectionHeader appearance] setBackgroundColor:[UIColor colorWithWhite:0.95 alpha:0.95]];
}

- (void)updateAppearance
{
    
}

@end
