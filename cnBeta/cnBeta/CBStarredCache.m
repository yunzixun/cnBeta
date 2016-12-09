//
//  CBStarredCache.m
//  cnBeta
//
//  Created by hudy on 2016/10/28.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "CBStarredCache.h"
#import "DataBase.h"
@interface CBStarredCache ()

@property (nonatomic, strong) NSMutableDictionary *cache;

@end

@implementation CBStarredCache

+ (instancetype)sharedCache;
{
    static CBStarredCache *cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[CBStarredCache alloc]init];
    });
    return cache;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _cache = [[NSMutableDictionary alloc]init];
        NSArray *articleIds = [[DataBase sharedDataBase] starredArticleIds];
        for (NSNumber *articleId in articleIds) {
            _cache[articleId] = @YES;
        }
    }
    return self;
}

- (void)starArticleWithId:(NSString *)sid
{
    _cache[sid] = @YES;
}

- (void)unstarArticleWithId:(NSString *)sid
{
    [_cache removeObjectForKey:sid];
}

- (BOOL)isStarred:(NSString *)articleId
{
    return _cache[articleId] != nil;
}

@end
