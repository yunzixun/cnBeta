//
//  DYKeyedHeightCache.m
//  cnBeta
//
//  Created by hudy on 16/9/16.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "DYKeyedHeightCache.h"

@interface DYKeyedHeightCache ()

@property (nonatomic,strong)NSCache *heightCache;

@end

@implementation DYKeyedHeightCache

- (NSCache *)heightCache
{
    if (!_heightCache) {
        _heightCache = [[NSCache alloc]init];
    }
    return _heightCache;
}

- (BOOL)existHeightForKey:(id)key;
{
    NSNumber *number = [self.heightCache objectForKey:key];
    return number && 1;
}

- (CGFloat)getHeightForKey:(id)key
{
#if CGFLOAT_IS_DOUBLE
    return [[self.heightCache objectForKey:key] doubleValue];
#else
    return [[self.heightCache objectForKey:key] floatValue];
#endif
}

- (void)cacheHeight:(CGFloat)height byKey:(id)key
{
    [self.heightCache setObject:[NSNumber numberWithFloat:height] forKey:key];
}

- (CGFloat)heightForCellWithModel: (id)model cachedByKey:(id)key configuration:(HeightConfigurationBlock)block
{
    CGFloat height = 0;
    if (![self existHeightForKey:key]) {
        height = block(model);
        [self cacheHeight:height byKey:key];
    } else {
        height = [self getHeightForKey:key];
    }
    return height;
}


@end
