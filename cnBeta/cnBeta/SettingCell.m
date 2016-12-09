//
//  SettingCell.m
//  cnBeta
//
//  Created by hudy on 16/8/8.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "SettingCell.h"
#import "SettingItem.h"
#import "SettingSwitchItem.h"
#import "SettingArrowItem.h"
#import "DYAppSettings.h"
#import "DYAppearanceManager.h"

@interface SettingCell ()

@property (nonatomic, strong)UIImageView *arrow;
@property (nonatomic, strong)UISwitch *switchview;

@end

@implementation SettingCell

- (UIImageView *)arrow
{
    if (!_arrow) {
        _arrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"CellArrow"]];
    }
    return _arrow;
}

-(UISwitch *)switchview
{
    if (!_switchview) {
        _switchview = [[UISwitch alloc]init];
        [_switchview addTarget:self action:@selector(switchchange) forControlEvents:UIControlEventValueChanged];
    }
    return _switchview;
}

- (void)switchchange
{    
    if ([self.delegate respondsToSelector:@selector(setState:forSwitch:)]) {
        
        [self.delegate setState:self.switchview.isOn forSwitch:self.item.title];
        [self.delegate reloadTableView];
        
    }
}

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *cellId = @"cell";
    SettingCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[SettingCell alloc]initWithStyle:UITableViewCellStyleSubtitle  reuseIdentifier:cellId];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        UIView *view = [[UIView alloc]init];
        view.backgroundColor = [UIColor colorWithRed:237/255.0 green:233/255.0 blue:218/255.0 alpha:1];
        self.selectedBackgroundView = view;
    }
    return self;
}

- (void)setItem:(SettingItem *)item
{
    _item = item;
    [self setupCell];
}


- (void)setupCell
{
    self.textLabel.text = _item.title;
    self.detailTextLabel.text = _item.subtitle;
    self.detailTextLabel.textColor = [UIColor lightGrayColor];
    self.textLabel.font = [[DYAppearanceManager sharedManager].CBFont fontWithSize:15];
    
    //NSLog(@"%@", _item.subtitle);
    
    if ([self.item isKindOfClass:[SettingSwitchItem class]]) {
        self.accessoryView = self.switchview;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.switchview.on = [self.delegate stateForSwitch:self.item.title];
        
    } else if ([self.item isKindOfClass:[SettingArrowItem class]]) {
        self.accessoryView = self.arrow;
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
        
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
