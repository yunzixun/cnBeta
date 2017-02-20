//
//  nestedLayoutView.m
//  cnBeta
//
//  Created by hudy on 16/7/16.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "nestedLayoutView.h"
#import "Constant.h"
#import "CBAppearanceManager.h"

@interface nestedLayoutView ()

//@property (nonatomic, strong)UILabel *nameLabel;
//@property (nonatomic, strong)UILabel *hostLabel;
//@property (nonatomic, strong)UILabel *

@end

@implementation nestedLayoutView

- (instancetype)initWithFrame:(CGRect)frame andModel:(commentModel *)commentItem upperView:(UIView *)upperView isLast:(BOOL)isLast
{
    if (self = [super initWithFrame:frame]) {
        if (!isLast) {
            self.layer.borderWidth = LayoutBordWidth;
            self.layer.borderColor = [UIColor cb_commentLayoutBorderLineColor].CGColor;
            self.backgroundColor = [UIColor cb_commentLayoutViewBackgroundColor];
        }
        UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, upperView.frame.size.height, frame.size.width - 10, 25)];
        nameLabel.font = NameFont;
        nameLabel.textColor = cmtNameColor;
        
        UILabel *hostLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, upperView.frame.size.height + 20, frame.size.width - 10, 20)];
        hostLabel.font = HostFont;
        hostLabel.textColor = HostColor;
        
        UILabel *floorLabel = [[UILabel alloc]initWithFrame:CGRectMake(frame.size.width - 40, upperView.frame.size.height + 5, 25, 15)];
        floorLabel.font = FloorFont;
        floorLabel.textColor = FloorColor;
        
        UILabel *commentLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, upperView.frame.size.height + 40, frame.size.width - 10, frame.size.height - upperView.frame.size.height - 40)];
        commentLabel.numberOfLines = 0;
        commentLabel.font = CommentFont;
        commentLabel.textColor = [UIColor cb_textColor];
        
        nameLabel.text = commentItem.name;
        hostLabel.text = [commentItem.host_name stringByAppendingString:[NSString stringWithFormat:@"  %@",commentItem.date]];
        commentLabel.text = commentItem.comment;
        floorLabel.text = commentItem.floor;
        
        [self addSubview:nameLabel];
        [self addSubview:hostLabel];
        [self addSubview:commentLabel];
        [self addSubview:floorLabel];
        
        if (isLast) {
            nameLabel.hidden = YES;
            hostLabel.hidden = YES;
            floorLabel.hidden = YES;
            commentLabel.frame = CGRectMake(5, upperView.frame.size.height + 10, frame.size.width - 10, frame.size.height - upperView.frame.size.height - 10);
        }
    }
    return self;
}

@end
