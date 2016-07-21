//
//  flooredCommentModel.m
//  cnBeta
//
//  Created by hudy on 16/7/14.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "flooredCommentModel.h"

@implementation flooredCommentModel

- (instancetype)initWithFlooredComment:(NSMutableArray *)flooredComment andTid:(NSString *)tid
{
    if (self = [super init]) {
        self.flooredComment = flooredComment;
        self.tid = tid;
    }
    return self;
}

@end
