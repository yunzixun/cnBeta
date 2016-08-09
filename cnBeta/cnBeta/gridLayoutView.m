//
//  gridLayoutView.m
//  cnBeta
//
//  Created by hudy on 16/7/15.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "gridLayoutView.h"
#import "commentModel.h"
#import "Constant.h"

@implementation gridLayoutView

- (instancetype)initWithFrame:(CGRect)frame andModelArray:(NSArray *)modelArray
{
    if (self = [super initWithFrame:frame]) {
        self.layer.borderWidth = LayoutBordWidth;
        self.layer.borderColor = LayoutBordColor.CGColor;
        self.backgroundColor = LayoutBackgroundColor;
        
        float lastHeight = 0;
        for (commentModel *commentItem in modelArray) {
            CGSize size = [commentItem sizeWithConstrainedSize:CGSizeMake(self.frame.size.width - 10, 0)];
            
            UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, lastHeight, frame.size.width - 10, 25)];
            nameLabel.font = NameFont;
            nameLabel.textColor = NameColor;
            
            UILabel *hostLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, lastHeight +20, frame.size.width - 10, 20)];
            hostLabel.font = HostFont;
            hostLabel.textColor = HostColor;
            
            UILabel *floorLabel = [[UILabel alloc]initWithFrame:CGRectMake(frame.size.width - 40, 5 + lastHeight, 25, 15)];
            floorLabel.font = FloorFont;
            floorLabel.textColor = FloorColor;
            
            UILabel *commentLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 50 + lastHeight, frame.size.width - 10, size.height + 10)];
            commentLabel.numberOfLines = 0;
            commentLabel.font = CommentFont;
            commentLabel.textColor = CommentColor;
            
            nameLabel.text = commentItem.name;
            hostLabel.text = commentItem.host_name;
            commentLabel.text = commentItem.comment;
            floorLabel.text = commentItem.floor;
            
            [self addSubview:nameLabel];
            [self addSubview:hostLabel];
            [self addSubview:commentLabel];
            [self addSubview:floorLabel];
            
            CGRect rect = CGRectMake(0, commentLabel.frame.origin.y + commentLabel.frame.size.height, self.frame.size.width, LayoutBordWidth);
            UIView *borderLineView = [[UIView alloc]initWithFrame:rect];
            borderLineView.backgroundColor = LayoutBordColor;
            if (commentItem != [modelArray lastObject]) {
                [self addSubview:borderLineView];
            }
            lastHeight = rect.origin.y;
        }
        
        CGRect frame = self.frame;
        frame.size.height = lastHeight;
        self.frame = frame;
    }
    return self;
}

@end
