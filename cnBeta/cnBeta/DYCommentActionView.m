//
//  DYCommentActionView.m
//  cnBeta
//
//  Created by hudy on 16/9/15.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "DYCommentActionView.h"
#import "Constant.h"
#import "commentModel.h"
#import "CBAppearanceManager.h"

@implementation DYCommentActionView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    _supportButton = [[DYCellButton alloc] initWithFrame:CGRectMake(10, 5, 55, 28)];
    _supportButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [_supportButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_supportButton setTitleColor:cb_redColor forState:UIControlStateHighlighted];
    [_supportButton setTitleColor:cb_redColor forState:UIControlStateSelected];
    [_supportButton setImage:[UIImage imageNamed:@"comment_support_n"] forState:UIControlStateNormal];
    [_supportButton setImage:[UIImage imageNamed:@"comment_support_p"] forState:UIControlStateHighlighted];
    [_supportButton setImage:[UIImage imageNamed:@"comment_support_p"] forState:UIControlStateSelected];
    [self addSubview:_supportButton];
    
    _opposeButton = [[DYCellButton alloc] initWithFrame:CGRectMake(80, 5, 55, 28)];
    _opposeButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [_opposeButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_opposeButton setTitleColor:cb_redColor forState:UIControlStateHighlighted];
    [_opposeButton setTitleColor:cb_redColor forState:UIControlStateSelected];
    [_opposeButton setImage:[UIImage imageNamed:@"comment_oppose_n"] forState:UIControlStateNormal];
    [_opposeButton setImage:[UIImage imageNamed:@"comment_oppose_p"] forState:UIControlStateHighlighted];
    [_opposeButton setImage:[UIImage imageNamed:@"comment_oppose_p"] forState:UIControlStateSelected];
    [self addSubview:_opposeButton];

    _replyButton = [[DYCellButton alloc] initWithFrame:CGRectMake(150, 10, 30, 18)];
    [_replyButton setTitle:@"回复" forState:UIControlStateNormal];
    [_replyButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_replyButton setTitleColor:cb_redColor forState:UIControlStateHighlighted];
    _replyButton.titleLabel.font = [[CBAppearanceManager sharedManager].CBFont fontWithSize:12];
    [self addSubview:_replyButton];
    self.frame = CGRectMake(1, 1, 220, 25);
}

- (void)setComment:(commentModel *)comment
{
    self.supportButton.commentInfo = comment;
    self.opposeButton.commentInfo = comment;
    self.replyButton.commentInfo = comment;
    [self.supportButton setTitle:comment.score forState:UIControlStateNormal];
    [self.opposeButton setTitle:comment.reason forState:UIControlStateNormal];
    self.supportButton.selected = comment.supported;
    self.opposeButton.selected = comment.opposed;
}

@end
