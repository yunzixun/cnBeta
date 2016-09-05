//
//  NSArray+transform.m
//  cnBeta
//
//  Created by hudy on 16/7/14.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "NSArray+transform.h"
#import "commentModel.h"
#import "flooredCommentModel.h"
#import "commentList.h"

@implementation NSArray (transform)

- (NSMutableArray *)convertToFlooredCommentArray//生成盖楼评论数组模型
{
    NSMutableArray *flooredCommentArray = [[NSMutableArray alloc]init];
    for (int i = (int)[self count]; i >  0 ; i--) {
        commentModel *comment = (commentModel *)self[i-1];
        flooredCommentModel *newFlooredComment;
        if (comment.pid.intValue != 0) {
            for (flooredCommentModel *flooredCommentItem in flooredCommentArray) {
                if (flooredCommentItem.tid == comment.pid) {
                    NSMutableArray *flooredcomment = [flooredCommentItem.flooredComment mutableCopy];//注意深复制
                    [flooredcomment addObject:comment];
                    newFlooredComment = [[flooredCommentModel alloc]initWithFlooredComment:flooredcomment andTid:comment.tid];
                    break;
                }
            }
            if (!newFlooredComment) {
                NSMutableArray *flooredcomment = [NSMutableArray array];
                [flooredcomment addObject:comment];
                newFlooredComment = [[flooredCommentModel alloc]initWithFlooredComment:flooredcomment andTid:comment.tid];
            }
        } else {
            NSMutableArray *flooredcomment = [NSMutableArray array];
            [flooredcomment addObject:comment];
            newFlooredComment = [[flooredCommentModel alloc]initWithFlooredComment:flooredcomment andTid:comment.tid];
        }
        [flooredCommentArray insertObject:newFlooredComment atIndex:0];
    }
    return flooredCommentArray;
}

- (NSMutableArray *)selectHotFlooredCommentArrayWithHotList:(NSArray *)hotList
{
    NSMutableArray *hotFlooredCommentArray = [NSMutableArray array];
    for (commentList *item in hotList) {
        for (flooredCommentModel *flooredcommentItem in self) {
            if ([flooredcommentItem.tid isEqualToString:item.tid]) {
                [hotFlooredCommentArray addObject:flooredcommentItem];
                break;
            }
        }
    }
    return hotFlooredCommentArray;
}

@end
