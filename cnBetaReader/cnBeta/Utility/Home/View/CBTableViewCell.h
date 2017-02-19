//
//  CBTableViewCell.h
//  cnBeta
//
//  Created by hudy on 2017/2/12.
//  Copyright © 2017年 hudy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsModel.h"

@interface CBTableViewCell : UITableViewCell

@property (nonatomic, strong)UIColor *titleColor;
@property (nonatomic, strong)NewsModel *newsModel;

@end
