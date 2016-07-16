//
//  NewsListCell.h
//  cnBeta
//
//  Created by hudy on 16/7/3.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataModel.h"
@interface NewsListCell : UITableViewCell

@property (nonatomic, strong)DataModel *newsModel;
@property (nonatomic,strong)UILabel *newstitle;

- (void)setNewsModel:(DataModel *)newsModel;

@end
