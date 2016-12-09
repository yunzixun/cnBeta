//
//  CBStarredCache.h
//  cnBeta
//
//  Created by hudy on 2016/10/28.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CBStarredCache : NSObject

+ (instancetype)sharedCache;

- (void)starArticleWithId:(NSString *)sid;

- (void)unstarArticleWithId:(NSString *)sid;

- (BOOL)isStarred:(NSString *)articleId;

@end
