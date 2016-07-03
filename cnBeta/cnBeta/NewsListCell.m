//
//  NewsListCell.m
//  cnBeta
//
//  Created by hudy on 16/7/3.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "NewsListCell.h"

@interface NewsListCell ()

@property (nonatomic,strong)UILabel *newstitle;
@property (nonatomic,strong)UILabel *time;

@end

@implementation NewsListCell

- (void)setNewsModel:(DataModel *)newsModel
{
    _newsModel = newsModel;
    for (UILabel *label in self.contentView.subviews) {
        [label removeFromSuperview];
    }
    //新闻标题
    _newstitle = [[UILabel alloc]initWithFrame:CGRectMake(20, 10, 340, 50)];
    _newstitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _newstitle.numberOfLines = 3;
    [_newstitle setText:newsModel.title];
    _newstitle.font = [UIFont systemFontOfSize:16];
    _newstitle.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_newstitle];
    //时间
    _time = [[UILabel alloc]initWithFrame:CGRectMake(20, 70, 300, 10)];
    _time.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_time setText:newsModel.parsedTime];
    _time.font = [UIFont systemFontOfSize:11];
    _time.textColor = [UIColor grayColor];
    _time.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_time];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
