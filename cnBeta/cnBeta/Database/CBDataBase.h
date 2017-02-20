//
//  CBDataBase.h
//  cnBeta
//
//  Created by hudy on 2016/10/4.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CBArticle.h"
#import "NewsModel.h"
#import "collectionModel.h"


@interface CBDataBase : NSObject

+ (instancetype)sharedDataBase;

- (void)prepareDataBase;

//查询已缓存文章
- (CBArticle *)articleWithSid:(NSString *)sid;

//缓存文章
- (void)cacheArticle:(CBArticle *)article;

- (BOOL)isCached:(NSString *)sid;

//查询已缓存列表新闻
- (NewsModel *)newsWithSid:(NSString *)sid;

//缓存列表新闻
- (void)cacheNews:(NewsModel *)news;

- (void)updateReadField:(NewsModel *)news;

- (NSArray *)newsListWithLastNews:(NewsModel *)lastNews limit:(NSInteger)limit;

- (void)starArticle:(collectionModel *)newsItem;

- (void)unstarArticle:(collectionModel *)newsItem;

- (NSMutableArray *)starredArticles;

- (void)deleteAllStarred;

- (NSArray *)starredArticleIds;

- (void)clearExpiredCache;


@end
