//
//  DYCommentActionView.h
//  cnBeta
//
//  Created by hudy on 16/9/15.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DYCellButton.h"
#import "commentModel.h"

@interface DYCommentActionView : UIView

@property(nonatomic, strong)DYCellButton *supportButton;
@property(nonatomic, strong)DYCellButton *opposeButton;
@property(nonatomic, strong)DYCellButton *replyButton;
@property(nonatomic, strong)commentModel *comment;

@end
