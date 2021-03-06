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
#import "CBAppearanceManager.h"
#import "UIColor+CBColor.h"

@implementation gridLayoutView

- (instancetype)initWithFrame:(CGRect)frame andModelArray:(NSArray *)modelArray
{
    if (self = [super initWithFrame:frame]) {
        self.layer.borderWidth = LayoutBordWidth;
        self.layer.borderColor = [UIColor cb_commentLayoutBorderLineColor].CGColor;
        self.backgroundColor = [UIColor cb_commentLayoutViewBackgroundColor];
        
        float lastHeight = 0;
        for (commentModel *commentItem in modelArray) {
            CGSize size = [commentItem sizeWithConstrainedSize:CGSizeMake(self.frame.size.width - 20, 0)];
            
            UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, lastHeight, frame.size.width - 10, 25)];
            nameLabel.font = NameFont;
            nameLabel.textColor = cmtNameColor;
            
            UILabel *hostLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, lastHeight +20, frame.size.width - 10, 20)];
            hostLabel.font = HostFont;
            hostLabel.textColor = HostColor;
            
            UILabel *floorLabel = [[UILabel alloc]initWithFrame:CGRectMake(frame.size.width - 40, 5 + lastHeight, 25, 15)];
            floorLabel.font = FloorFont;
            floorLabel.textColor = FloorColor;
            
            UILabel *commentLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 40 + lastHeight, frame.size.width - 10, size.height + 15)];
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
            
            CGRect rect = CGRectMake(0, commentLabel.frame.origin.y + commentLabel.frame.size.height, self.frame.size.width, LayoutBordWidth);
            UIView *borderLineView = [[UIView alloc]initWithFrame:rect];
            borderLineView.backgroundColor = [UIColor cb_commentLayoutBorderLineColor];
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
