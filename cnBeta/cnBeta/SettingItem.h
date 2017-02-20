//
//  SettingItem.h
//  cnBeta
//
//  Created by hudy on 16/8/8.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^SettingItemOption)();
@interface SettingItem : NSObject

@property (nonatomic, copy)NSString *title;
@property (nonatomic, copy)NSString *subtitle;
@property (nonatomic, strong)SettingItemOption option;


+ (instancetype)itemWithTitle:(NSString *)title;
+ (instancetype)itemWithTitle:(NSString *)title subtitle:(NSString *)subtitle;

@end
