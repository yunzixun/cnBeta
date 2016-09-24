//
//  commentCell.h
//  cnBeta
//
//  Created by hudy on 16/7/6.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "flooredCommentModel.h"
#import "DYCellButton.h"
@protocol replyActionDelegate;

@interface commentCell : UITableViewCell
@property (nonatomic, weak) id<replyActionDelegate>delegate;
@property (nonatomic, strong)flooredCommentModel *flooredCommentItem;
@property (nonatomic, strong)NSIndexPath *indexPath;
@property (weak, nonatomic) IBOutlet UILabel *floor;

+ (instancetype)cellWithTableView:(UITableView *)tableView Identifier:(NSString *)cellId;

@end


@protocol replyActionDelegate <NSObject>

- (void)reply:(DYCellButton *)button;
- (void)support:(DYCellButton *)button;
- (void)oppose:(DYCellButton *)button;

@end
