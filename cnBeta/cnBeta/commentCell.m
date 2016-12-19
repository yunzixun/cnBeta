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
#import "DYCommentActionView.h"
#import "CBAppearanceManager.h"

@interface commentCell ()

@property (weak, nonatomic) IBOutlet UIImageView *headImage;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *host;
@property (weak, nonatomic) IBOutlet UIView  *commentView;
@property (weak, nonatomic) IBOutlet UIView *commentActionView;



@end

@implementation commentCell

+ (instancetype)cellWithTableView:(UITableView *)tableView Identifier:(NSString *)cellId
{
    commentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];

    return cell;
}

- (void)setFlooredCommentItem:(flooredCommentModel *)flooredCommentItem
{
    _flooredCommentItem = flooredCommentItem;
    commentModel *commentInfo = [flooredCommentItem.flooredComment lastObject];
    _floor.text = commentInfo.floor;
    _name.text = commentInfo.name;
    _host.text = [commentInfo.host_name stringByAppendingString:[NSString stringWithFormat:@"  %@",commentInfo.date]];
    
    _floor.font = FloorFont;
    _name.font = NameFont;
    _host.font = HostFont;
    
    [_headImage sd_setImageWithURL:[NSURL URLWithString:commentInfo.icon] placeholderImage:[UIImage imageNamed:@"me_cell_nolandheader_66x66_"]];
    
    
    for (UIView *view in _commentView.subviews) {
        [view removeFromSuperview];
    }
    LayoutCommentView *commentView = [[LayoutCommentView alloc]initWithModel:flooredCommentItem];
    CGRect frame = _commentView.frame;
    frame.size.height = commentView.frame.size.height;
    _commentView.frame = frame;
    [_commentView addSubview:commentView];
    //_commentView = commentView;
    
    for (UIView *view in _commentActionView.subviews) {
        [view removeFromSuperview];
    }
    DYCommentActionView *commentActionView = [[DYCommentActionView alloc] initWithFrame:CGRectMake(0, 0, 240, 25)];
    commentActionView.comment = commentInfo;
    [self.commentActionView addSubview:commentActionView];
    [self setCommentActions:commentActionView];
    
}

- (void)setCommentActions:(DYCommentActionView *)commentActionView
{
    commentActionView.supportButton.indexPath = self.indexPath;
    commentActionView.opposeButton.indexPath = self.indexPath;
    commentActionView.replyButton.indexPath = self.indexPath;
    
    [commentActionView.supportButton addTarget:self.delegate action:@selector(support:) forControlEvents:UIControlEventTouchUpInside];
    [commentActionView.opposeButton addTarget:self.delegate action:@selector(oppose:) forControlEvents:UIControlEventTouchUpInside];
    [commentActionView.replyButton addTarget:self.delegate action:@selector(reply:) forControlEvents:UIControlEventTouchUpInside];
}

//- (IBAction)replyAction:(UIButton *)sender {
//    commentModel *commentItem = _flooredCommentItem.flooredComment.lastObject;
//    if ([self.delegate respondsToSelector:@selector(replyWithTid:)]) {
//        [self.delegate replyWithTid:commentItem.tid];
//    }
//    
//}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
