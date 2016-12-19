//
//  NewsListCell.h
//  cnBeta
//
//  Created by hudy on 16/7/3.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsModel.h"

@interface NewsListCell : UITableViewCell

@property (nonatomic,strong)UILabel *newstitle;
@property (nonatomic, strong)NewsModel *newsModel;

+ (instancetype)cellWithTableView:(UITableView *)tableView;
- (void)setNewsModel:(NewsModel *)newsModel;

@end
