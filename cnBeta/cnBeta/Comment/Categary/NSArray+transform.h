//
//  NSArray+transform.h
//  cnBeta
//
//  Created by hudy on 16/7/14.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (transform)

- (NSMutableArray *)convertToFlooredCommentArray;
- (NSMutableArray *)selectHotFlooredCommentArrayWithHotList:(NSArray *)hotList;

@end
