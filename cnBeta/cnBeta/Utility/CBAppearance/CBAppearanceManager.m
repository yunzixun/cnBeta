//
//  CBAppearanceManager.m
//  cnBeta
//
//  Created by hudy on 16/8/26.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "CBAppearanceManager.h"
#import "CBSectionHeader.h"
#import "CBCommentToolbar.h"
#import "CBAppSettings.h"
#import "NavTabBar.h"
#import "NavTabButton.h"
#import "CBCmtListHeaderView.h"
#import "CBCmtPostHeaderView.h"
#import "CBNewsListTableView.h"
#import "CBNewsListCell.h"

@interface CBAppearanceManager ()

@property (nonatomic, readwrite, strong)UIFont *CBFont;
@property (nonatomic, readwrite, strong)UIFont *CBCommentFont;

@end

@implementation CBAppearanceManager

- (void)dealloc
{
    [[CBAppSettings sharedSettings] removeObserver:self forKeyPath:@"nightMode" context:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

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
    CBAppSettings *settings = [CBAppSettings sharedSettings];
    [settings addObserver:self forKeyPath:@"nightMode" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];

    if ([[UIDevice currentDevice] systemVersion].floatValue >= 8.0) {
        _CBFont = settings.thinFontEnabled ? [UIFont fontWithName:@".PingFang-SC-Light" size:15]:[UIFont systemFontOfSize:15];
    }else{
        _CBFont = [UIFont systemFontOfSize:15];
    }
    _CBCommentFont = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? [_CBFont fontWithSize:16] : [_CBFont fontWithSize:15];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCBFont) name:CBAppSettingFontChangedNotification object:nil];
//        [[NSNotificationCenter defaultCenter] addObserverForName:CBAppSettingThemeChangedNotification object:[CBAppSettings sharedSettings] queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
//            [self updateAppearance:YES];
//        }];
        [self updateAppearance:NO];
    });
}


- (void)updateCBFont
{
    CBAppSettings *settings = [CBAppSettings sharedSettings];
    _CBFont = settings.thinFontEnabled ? [UIFont fontWithName:@".PingFang-SC-Light" size:15]:[UIFont systemFontOfSize:15];
    _CBCommentFont = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? [_CBFont fontWithSize:16] : [_CBFont fontWithSize:15];
}

- (void)updateAppearance:(BOOL)reload
{
    if ([CBAppSettings sharedSettings].isNightMode) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        [[UITabBar appearance] setBarStyle:UIBarStyleBlack];
        [[UINavigationBar appearance] setBarTintColor:[UIColor blackColor]];
        [[UIActivityIndicatorView appearance] setColor:[UIColor whiteColor]];
        [[UIToolbar appearance] setBarStyle:UIBarStyleBlack];

        //[[UINavigationBar appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIColor blackColor]}];
        [[NavTabBar appearance] setBackgroundColor:[UIColor blackColor]];
        
        
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        [[UITabBar appearance] setBarStyle:UIBarStyleDefault];
        [[UINavigationBar appearance] setBarTintColor:globalColor];
        [[UIActivityIndicatorView appearance] setColor:[UIColor blackColor]];
        [[UIToolbar appearance] setBarStyle:UIBarStyleDefault];

        [[NavTabBar appearance] setBackgroundColor:[UIColor whiteColor]];

    }
    [[CBSectionHeader appearance] setBackgroundColor:[UIColor cb_sectionHeaderViewBackgroundColor]];
    [[NavTabButton appearance] setTitleColor:[UIColor cb_textColor]];
    [[CBNewsListTableView appearance] setSeparatorColor:[UIColor cb_newsTableViewSeparatorColor]];
    [[CBCmtListHeaderView appearance] setBackgroundColor:[UIColor cb_backgroundColor]];
    [[CBCmtPostHeaderView appearance] setBackgroundColor:[UIColor cb_backgroundColor]];
    [[UITableViewCell appearance] setBackgroundColor:[UIColor cb_tableViewCellBackgroundColor]];
    [[CBNewsListTableView appearance] setBackgroundColor:[UIColor cb_newsTableViewBackgroundColor]];

    
    if (reload) {
        NSArray *windows = [UIApplication sharedApplication].windows;
        for (UIWindow *window in windows) {
            for (UIView *view in window.subviews) {
                [view removeFromSuperview];
                [window addSubview:view];
            }
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"nightMode"]) {
        [self updateAppearance:YES];
    }
}

@end
