//
//  DYCommentActionView.h
//  cnBeta
//
//  Created by hudy on 16/9/15.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBCellButton.h"
#import "commentModel.h"

@interface CBCommentActionView : UIView

@property(nonatomic, strong)CBCellButton *supportButton;
@property(nonatomic, strong)CBCellButton *opposeButton;
@property(nonatomic, strong)CBCellButton *replyButton;
@property(nonatomic, strong)commentModel *comment;

@end
