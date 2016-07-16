//
//  collectionTableViewCell.h
//  cnBeta
//
//  Created by hudy on 16/7/8.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "collectionModel.h"

@interface collectionTableViewCell : UITableViewCell

@property (nonatomic, strong)collectionModel *newsInfo;

- (void)setNewsInfo:(collectionModel *)newsInfo;

@end
