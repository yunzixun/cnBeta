//
//  DYKeyedHeightCache.h
//  cnBeta
//
//  Created by hudy on 16/9/16.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef CGFloat(^HeightConfigurationBlock)(id model);

@interface DYKeyedHeightCache : NSObject

//- (BOOL)existHeightForKey:(id)key;
- (void)cacheHeight:(CGFloat)height byKey:(id)key;
- (CGFloat)heightForCellWithModel: (id)model cachedByKey:(id)key configuration:(HeightConfigurationBlock)block;

@end
