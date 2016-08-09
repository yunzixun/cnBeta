//
//  SettingItem.m
//  cnBeta
//
//  Created by hudy on 16/8/8.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "SettingItem.h"

@implementation SettingItem


+ (instancetype)itemWithTitle:(NSString *)title
{
    return [self itemWithTitle:title subtitle:nil];
}

+ (instancetype)itemWithTitle:(NSString *)title subtitle:(NSString *)subtitle
{
    /**
    创建item时， 必须是[self alloc]，而不能是[SettingItem alloc], 否则子类无法判断类型。 被坑哭了。。。。。
     */
    SettingItem *item = [[self alloc]init];
    item.title = title;
    item.subtitle = subtitle;
    return item;
}
@end
