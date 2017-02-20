//
//  flooredCommentModel.h
//  cnBeta
//
//  Created by hudy on 16/7/14.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface flooredCommentModel : NSObject

@property (nonatomic, copy)NSString *tid;
@property (nonatomic, strong)NSMutableArray *flooredComment;

- (instancetype)initWithFlooredComment:(NSMutableArray *)flooredComment andTid:(NSString *)tid;

@end
