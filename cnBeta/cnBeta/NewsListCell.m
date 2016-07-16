//
//  NewsListCell.m
//  cnBeta
//
//  Created by hudy on 16/7/3.
//  Copyright © 2016年 hudy. All rights reserved.
//

#define SCREEN_WIDTH                    ([UIScreen mainScreen].bounds.size.width)

#import "NewsListCell.h"
#import "UIImageView+WebCache.h"

@interface NewsListCell ()

@property (nonatomic,strong)UILabel *time;
@property (strong, nonatomic)UIImageView *imageThumb;


@end

@implementation NewsListCell

- (void)setNewsModel:(DataModel *)newsModel
{
    _newsModel = newsModel;
    for (UILabel *label in self.contentView.subviews) {
        [label removeFromSuperview];
    }
    //新闻标题
    _newstitle = [[UILabel alloc]initWithFrame:CGRectMake(120, 10, SCREEN_WIDTH-10-120, 50)];
    _newstitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _newstitle.numberOfLines = 3;
    [_newstitle setText:newsModel.title];
    _newstitle.font = [UIFont systemFontOfSize:16];
    _newstitle.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_newstitle];
    //时间
    _time = [[UILabel alloc]initWithFrame:CGRectMake(120, 70, 250, 10)];
    _time.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_time setText:newsModel.pubtime];
    _time.font = [UIFont systemFontOfSize:11];
    _time.textColor = [UIColor grayColor];
    _time.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_time];
    //NSLog(@"%@", newsModel.thumb);
    //图片
    _imageThumb = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 90, 70)];
    [self.contentView addSubview:_imageThumb];
    [self.imageThumb sd_setImageWithURL:[NSURL URLWithString:newsModel.thumb] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    
    
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:newsModel.thumb]  options:NSDataReadingMappedIfSafe error:NULL];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            UIImage *image = [UIImage imageWithData:imageData];
//            self.imageThumb.image = image;
//        });
//    });
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
