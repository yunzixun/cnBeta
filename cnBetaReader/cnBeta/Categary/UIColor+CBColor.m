//
//  UIColor+CBColor.m
//  cnBeta
//
//  Created by hudy on 2016/12/31.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "UIColor+CBColor.h"
#import "CBAppSettings.h"

@implementation UIColor (CBColor)

//UIWebView,statusBarBackground,headerView
+ (instancetype)cb_backgroundColor
{
    return [CBAppSettings sharedSettings].isNightMode ? [UIColor colorWithRed:50/255. green:50/255. blue:50/255. alpha:1] : [UIColor whiteColor];
}

+ (instancetype)cb_navTabMainViewBackgroundColor
{
    return [CBAppSettings sharedSettings].isNightMode ? [UIColor colorWithRed:30/255. green:30/255. blue:30/255. alpha:1] : [UIColor whiteColor];
}

+ (instancetype)cb_lineViewBackgroundColor
{
    return [CBAppSettings sharedSettings].isNightMode ? [UIColor colorWithRed:40/255. green:40/255. blue:40/255. alpha:1] : [UIColor colorWithRed:216/255.0f green:216/255.0f blue:216/255.0f alpha:1];
}

+ (instancetype)cb_tableViewCellBackgroundColor
{
    return [CBAppSettings sharedSettings].isNightMode ? [UIColor colorWithRed:50/255. green:50/255. blue:50/255. alpha:1] : [UIColor whiteColor];

}

+ (instancetype)cb_newsTableViewBackgroundColor
{
    return [CBAppSettings sharedSettings].isNightMode ? [UIColor colorWithRed:30/255. green:30/255. blue:30/255. alpha:1] : [UIColor colorWithRed:240/255. green:240/255. blue:240/255. alpha:1];
}

+ (instancetype)cb_newsTableViewSeparatorColor
{
    return [CBAppSettings sharedSettings].isNightMode ? [UIColor colorWithRed:40/255. green:40/255. blue:40/255. alpha:1] : [UIColor grayColor];
}

+ (instancetype)cb_cmtListTitleBackgroundColor
{
    return [CBAppSettings sharedSettings].isNightMode ? [UIColor darkGrayColor] : [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1];
}

+ (instancetype)cb_settingViewBackgroundColor
{
    return [CBAppSettings sharedSettings].isNightMode ? [UIColor colorWithRed:40/255. green:40/255. blue:40/255. alpha:1] : [UIColor colorWithRed:240/255. green:240/255. blue:240/255. alpha:1];
}

+ (instancetype)cb_settingTableViewSeparatorColor
{
    return [CBAppSettings sharedSettings].isNightMode ? [UIColor darkGrayColor] : [UIColor lightGrayColor];

}

+ (instancetype)cb_textColor
{
    return [CBAppSettings sharedSettings].isNightMode ? [UIColor colorWithRed:207/255. green:207/255. blue:207/255. alpha:1] : [UIColor blackColor];
}

+ (instancetype)cb_textBackgroundColor
{
    return [UIColor colorWithRed:40/255. green:40/255. blue:40/255. alpha:1];
}

+ (instancetype)cb_sectionHeaderViewBackgroundColor
{
    return [CBAppSettings sharedSettings].isNightMode ? [UIColor darkGrayColor] : [UIColor colorWithWhite:0.95 alpha:0.95];
}

+ (instancetype)cb_commentLayoutViewBackgroundColor
{
    return [CBAppSettings sharedSettings].isNightMode ? [UIColor darkGrayColor] : LayoutBackgroundColor;
}

+ (instancetype)cb_commentLayoutBorderLineColor
{
    return [CBAppSettings sharedSettings].isNightMode ? [UIColor colorWithRed:40/255. green:40/255. blue:40/255. alpha:1] : LayoutBordColor;
}

+ (instancetype)cb_shareUIBackgroundColor
{
    return [CBAppSettings sharedSettings].isNightMode ? [UIColor darkGrayColor] : [UIColor whiteColor];
}


@end
