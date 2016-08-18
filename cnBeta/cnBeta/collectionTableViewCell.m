//
//  collectionTableViewCell.m
//  cnBeta
//
//  Created by hudy on 16/7/8.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "collectionTableViewCell.h"
#import "Constant.h"

@interface collectionTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *title;

@property (weak, nonatomic) IBOutlet UILabel *date;

@end
@implementation collectionTableViewCell


- (void)setNewsInfo:(collectionModel *)newsInfo
{
    _newsInfo = newsInfo;
    self.title.text = newsInfo.title;
    self.title.frame = CGRectMake(15, 10, ScreenWidth - 70, 35);
    self.date.text = [NSString stringWithFormat:@"收藏于%@", newsInfo.time];
    UIImageView *imageView = [[UIImageView alloc]init];
    [imageView sd_setImageWithURL:[NSURL URLWithString:newsInfo.thumb] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    imageView.frame = CGRectMake(ScreenWidth - 60, 5, 50, 50);
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.layer.cornerRadius = imageView.frame.size.height/2;
    imageView.layer.masksToBounds = YES;
    self.accessoryView = imageView;
}




@end
