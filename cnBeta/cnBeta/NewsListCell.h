//
//  NewsListCell.h
//  cnBeta
//
//  Created by hudy on 16/7/3.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataModel.h"
#import "HotNewsModel.h"

@interface NewsListCell : UITableViewCell

@property (nonatomic,strong)UILabel *newstitle;
@property (nonatomic, strong)DataModel *newsModel;
@property (nonatomic, strong)HotNewsModel *hotNewsModel;

+ (instancetype)cellWithTableView:(UITableView *)tableView;
- (void)setNewsModel:(DataModel *)newsModel;

-(void)setHotNewsModel:(HotNewsModel *)hotNewsModel;

@end
