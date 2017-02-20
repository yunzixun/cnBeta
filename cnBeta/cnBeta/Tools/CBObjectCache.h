//
//  CBObjectCache.h
//  cnBeta
//
//  Created by hudy on 2016/12/14.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CBObjectCache : NSObject

@property (nonatomic, assign) NSInteger maxCacheAge;
@property (nonatomic, assign) NSInteger maxCacheSize;

+ (instancetype)sharedCache;

- (void)storeObject:(id<NSCoding>)object forKey:(NSString *)key;
- (void)storeObject:(id<NSCoding>)object forKey:(NSString *)key toDisk:(BOOL)toDisk;

- (id)objectForKey:(NSString *)key;
- (id)objectFromMemoryCacheForKey:(NSString *)key;
- (id)objectFromDiskCacheForKey:(NSString *)key;

- (void)clearMemoryCache;
- (void)clearDiskCache;
- (void)clearDiskCacheOnCompletion:(void (^)())completion;
- (void)clearExpiredDiskCache;

- (void)calculateCacheSize:(void (^)(float))completion;

@end
