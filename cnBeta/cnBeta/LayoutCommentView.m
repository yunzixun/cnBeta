//
//  LayoutCommentView.m
//  cnBeta
//
//  Created by hudy on 16/7/15.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "LayoutCommentView.h"
#import "gridLayoutView.h"
#import "nestedLayoutView.h"
#import "commentModel.h"
#import "Constant.h"


@implementation LayoutCommentView

- (instancetype)initWithModel:(flooredCommentModel *)model
{
    if (self = [super initWithFrame:CGRectZero]) {
        NSMutableArray *flooredComment = [NSMutableArray arrayWithArray:model.flooredComment];
        [self updateWithModelArray:flooredComment];
    }
    return self;
}

- (void)updateWithModelArray:(NSMutableArray *)flooredComment
{
    id lastView = nil;
    float lastHeight = 0;

    if (flooredComment.count > MaxOverlapNumber) {
        NSMutableArray *tempArray = [[NSMutableArray alloc]initWithArray:flooredComment];
        [tempArray removeObjectsInRange:NSMakeRange(flooredComment.count - MaxOverlapNumber, MaxOverlapNumber)];
        CGRect rect = CGRectMake(MaxOverlapNumber * OverlapSpace, 10 + MaxOverlapNumber * OverlapSpace, ScreenWidth - 40 -10 - 2*(MaxOverlapNumber * OverlapSpace), 0);
        gridLayoutView *gridView = [[gridLayoutView alloc]initWithFrame:rect andModelArray:tempArray];
        lastHeight = gridView.frame.size.height;
        [self addSubview:gridView];
        lastView = gridView;
        [flooredComment removeObjectsInRange:NSMakeRange(0, flooredComment.count - MaxOverlapNumber)];
    }

    int floorCnt = (int)flooredComment.count;
    for (int i = 0; i < floorCnt; i++) {
        commentModel *commentItem = flooredComment[i];
        int dif = floorCnt - i -1;
        CGRect rect = CGRectMake(dif * OverlapSpace, 10 + dif * OverlapSpace, ScreenWidth - 40 -10 - 2*(dif * OverlapSpace), 0);
        CGSize size = [commentItem sizeWithConstrainedSize:CGSizeMake(rect.size.width - 10, 0)];
        rect.size.height = size.height + lastHeight + (i == floorCnt - 1 ? 10 : 50);
        
        nestedLayoutView *nestedView = [[nestedLayoutView alloc]initWithFrame:rect andModel:commentItem upperView:lastView isLast:i == floorCnt-1 ];
        lastHeight = rect.size.height;
        
        if (lastView) {
            [self insertSubview:nestedView belowSubview:lastView];
        } else {
            [self addSubview:nestedView];
        }
        lastView = nestedView;
    }
    self.frame = CGRectMake(44, 0, ScreenWidth, lastHeight + 10);
    

}

@end
