//
//  SettingCell.h
//  cnBeta
//
//  Created by hudy on 16/8/8.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SettingItem;

@interface SettingCell : UITableViewCell
@property (nonatomic, strong)SettingItem *item;

+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end
