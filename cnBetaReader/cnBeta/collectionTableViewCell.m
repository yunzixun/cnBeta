//
//  collectionTableViewCell.m
//  cnBeta
//
//  Created by hudy on 16/7/8.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "collectionTableViewCell.h"
#import "Constant.h"
#import "UIImageView+CircleCorner.h"
#import "CBAppearanceManager.h"
#import "UIColor+CBColor.h"

@interface collectionTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *title;

@property (weak, nonatomic) IBOutlet UILabel *date;


@end
@implementation collectionTableViewCell


- (void)setNewsInfo:(collectionModel *)newsInfo
{
    _newsInfo = newsInfo;
    self.title.text = newsInfo.title;
    self.date.text = [NSString stringWithFormat:@"收藏于%@", newsInfo.time];
    self.title.font = [[CBAppearanceManager sharedManager].CBFont fontWithSize:14];
    self.title.textColor = [UIColor cb_textColor];
    self.date.font = [[CBAppearanceManager sharedManager].CBFont fontWithSize:10];
    
    UIImageView *imageView = [[UIImageView alloc]init];
    [imageView sd_setImageWithURL:[NSURL URLWithString:newsInfo.thumb] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    imageView.bounds = CGRectMake(0, 0, 50, 50);
    
    imageView.layer.cornerRadius = imageView.frame.size.height/2;
    imageView.layer.masksToBounds = YES;
    imageView.layer.shouldRasterize = YES;
    imageView.layer.rasterizationScale =[UIScreen mainScreen].scale;
    
//    imageView1 = [imageView1 imageWithRoundedCornersSize:imageView.bounds.size.height/2];
//    imageView.image = imageView1.image;
    
    
    self.accessoryView = imageView;

}


//imageView.contentMode = UIViewContentModeScaleAspectFit;
//    imageView.layer.cornerRadius = imageView.frame.size.height/2;
//    imageView.layer.masksToBounds = YES;


@end
