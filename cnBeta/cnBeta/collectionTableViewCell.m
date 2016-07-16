//
//  collectionTableViewCell.m
//  cnBeta
//
//  Created by hudy on 16/7/8.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "collectionTableViewCell.h"

@interface collectionTableViewCell ()


@end
@implementation collectionTableViewCell

- (void)setNewsInfo:(collectionModel *)newsInfo
{
    _newsInfo = newsInfo;
    self.textLabel.text = newsInfo.title;
    self.detailTextLabel.text = newsInfo.time;
}


@end
