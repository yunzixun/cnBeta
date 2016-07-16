//
//  commentCell.m
//  cnBeta
//
//  Created by hudy on 16/7/6.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "commentCell.h"

@interface commentCell ()

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *host;
@property (weak, nonatomic) IBOutlet UILabel *comment;
@property (weak, nonatomic) IBOutlet UILabel *upFinger;
@property (weak, nonatomic) IBOutlet UILabel *downFinger;
@property (weak, nonatomic) IBOutlet UIImageView *support;
@property (weak, nonatomic) IBOutlet UIImageView *opposition;

@end

@implementation commentCell

- (void)setCommentInfo:(commentModel *)commentInfo
{
    _commentInfo = commentInfo;
    _name.text = commentInfo.name;
    _host.text = commentInfo.host_name;
    _comment.text = commentInfo.comment;
    _upFinger.text = commentInfo.score;
    _downFinger.text = commentInfo.reason;
    _support.image = [UIImage imageNamed:@"like_btn"];
    _opposition.image = [UIImage imageNamed:@"like_btn"];
    _opposition.transform = CGAffineTransformMakeRotation(M_PI);
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
