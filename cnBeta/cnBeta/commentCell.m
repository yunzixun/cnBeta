//
//  commentCell.m
//  cnBeta
//
//  Created by hudy on 16/7/6.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "commentCell.h"
#import "commentModel.h"
#import "LayoutCommentView.h"

@interface commentCell ()

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *host;
@property (weak, nonatomic) IBOutlet UIView  *commentView;
@property (weak, nonatomic) IBOutlet UILabel *upFinger;
@property (weak, nonatomic) IBOutlet UILabel *downFinger;
@property (weak, nonatomic) IBOutlet UIImageView *support;
@property (weak, nonatomic) IBOutlet UIImageView *opposition;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;

@end

@implementation commentCell

- (void)setFlooredCommentItem:(flooredCommentModel *)flooredCommentItem
{
    _flooredCommentItem = flooredCommentItem;
    commentModel *commentInfo = [flooredCommentItem.flooredComment lastObject];
    _floor.text = commentInfo.floor;
    _name.text = commentInfo.name;
    _host.text = commentInfo.host_name;
    _upFinger.text = commentInfo.score;
    _downFinger.text = commentInfo.reason;
    _support.image = [UIImage imageNamed:@"score"];
    _opposition.image = [UIImage imageNamed:@"reason"];
    //[_replyButton setBackgroundImage:[UIImage imageNamed:@"reply"] forState:UIControlStateNormal];
    //[_replyButton setTitle:nil forState:UIControlStateNormal];
    //_opposition.transform = CGAffineTransformMakeRotation(M_PI);
    
    for (UIView *view in _commentView.subviews) {
        [view removeFromSuperview];
    }
    LayoutCommentView *commentView = [[LayoutCommentView alloc]initWithModel:flooredCommentItem];
    CGRect frame = _commentView.frame;
    frame.size.height = commentView.frame.size.height;
    //frame.size.width = commentView.frame.size.width;
    _commentView.frame = frame;
    [_commentView addSubview:commentView];
}
- (IBAction)replyAction:(UIButton *)sender {
    commentModel *commentItem = _flooredCommentItem.flooredComment.lastObject;
    if ([self.delegate respondsToSelector:@selector(showReplyActionsWithTid:)]) {
        [self.delegate showReplyActionsWithTid:commentItem.tid];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
