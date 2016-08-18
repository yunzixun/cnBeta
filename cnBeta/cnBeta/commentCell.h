//
//  commentCell.h
//  cnBeta
//
//  Created by hudy on 16/7/6.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "flooredCommentModel.h"
@protocol replyActionDelegate;

@interface commentCell : UITableViewCell
@property (nonatomic, weak) id<replyActionDelegate>delegate;
@property (nonatomic, strong)flooredCommentModel *flooredCommentItem;
@property (weak, nonatomic) IBOutlet UILabel *floor;

+ (instancetype)cellWithTableView:(UITableView *)tableView forIndexPath:(NSIndexPath *)indexPath;

@end


@protocol replyActionDelegate <NSObject>

- (void)showReplyActionsWithTid:(NSString *)tid;

@end