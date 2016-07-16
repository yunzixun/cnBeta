//
//  commentCell.h
//  cnBeta
//
//  Created by hudy on 16/7/6.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "commentModel.h"

@interface commentCell : UITableViewCell
@property  (nonatomic, strong)commentModel *commentInfo;
@property (weak, nonatomic) IBOutlet UILabel *floor;
@end
