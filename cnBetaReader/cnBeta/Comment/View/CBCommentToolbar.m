//
//  CBCommentToolbar.m
//  cnBeta
//
//  Created by hudy on 2016/12/21.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "CBCommentToolbar.h"
#import "CBAppSettings.h"

@implementation CBCommentToolbar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    
    //UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 49)];
    [backBtn setImage:[UIImage imageNamed:@"toolbar_back_normal_50x50_"] forState:UIControlStateNormal];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    _backBtn = backBtn;
    
    UIButton *commentBtn = [[UIButton alloc] initWithFrame:CGRectMake(60, 0, 60, 44)];
    [commentBtn setImage:[UIImage imageNamed:@"comment_edit_n"] forState:UIControlStateNormal];
    UIBarButtonItem *commentItem = [[UIBarButtonItem alloc] initWithCustomView:commentBtn];
    _commentBtn = commentBtn;
    
    UIButton *refreshBtn = [[UIButton alloc] initWithFrame:CGRectMake(60, 0, 60, 49)];
    if ([CBAppSettings sharedSettings].isNightMode) {
        [refreshBtn setImage:[UIImage imageNamed:@"toolbar_refresh_normal_night_50x50_"] forState:UIControlStateNormal];
    } else {
        [refreshBtn setImage:[UIImage imageNamed:@"toolbar_refresh_normal_50x50_"] forState:UIControlStateNormal];
    }
    UIBarButtonItem *REfreshItem = [[UIBarButtonItem alloc] initWithCustomView:refreshBtn];
    _refreshBtn = refreshBtn;
    
    UIButton *toBottomBtn = [[UIButton alloc] initWithFrame:CGRectMake(60, 0, 60, 49)];
    if ([CBAppSettings sharedSettings].isNightMode) {
        [toBottomBtn setImage:[UIImage imageNamed:@"toolbar_toBottom_normal_night_50x50_"] forState:UIControlStateNormal];
    } else {
        [toBottomBtn setImage:[UIImage imageNamed:@"toolbar_toBottom_normal_50x50_"] forState:UIControlStateNormal];
    }
    UIBarButtonItem *toBottomItem = [[UIBarButtonItem alloc] initWithCustomView:toBottomBtn];
    _toBottomBtn = toBottomBtn;
    
    UIBarButtonItem *fixedItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedItem.width = -3;
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [self setItems:@[fixedItem, backItem, flexibleItem, commentItem, flexibleItem, REfreshItem, flexibleItem, toBottomItem, fixedItem]];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
