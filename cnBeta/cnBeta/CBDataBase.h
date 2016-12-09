//
//  CBDataBase.h
//  cnBeta
//
//  Created by hudy on 2016/10/4.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CBArticle.h"


@interface CBDataBase : NSObject

+ (instancetype)sharedDataBase;

- (void)prepareDataBase;

//查询已缓存文章
- (CBArticle *)articleWithSid:(NSString *)sid;

//缓存文章
- (void)cacheArticle:(CBArticle *)article;

- (void)clearExpiredCache;


@end
