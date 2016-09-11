//
//  SettingCell.h
//  cnBeta
//
//  Created by hudy on 16/8/8.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SettingItem;
@protocol SwitchControlDelegate;

@interface SettingCell : UITableViewCell
@property (nonatomic, strong)SettingItem *item;
@property (nonatomic, weak) id<SwitchControlDelegate> delegate;

+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end

@protocol SwitchControlDelegate <NSObject>

- (void)setState: (BOOL)isOn forSwitch: (NSString *)switchName;

- (BOOL)stateForSwitch: (NSString *)switchName;

@end
