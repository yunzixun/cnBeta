//
//  DataBase.h
//  cnBeta
//
//  Created by hudy on 16/7/8.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "collectionModel.h"
#import "sqlite3.h"
#import "CBArticle.h"

@interface DataBase : NSObject
{
    sqlite3 *database;
    dispatch_queue_t ioQueue;
    
}
//@property (nonatomic, strong) NSNumber *version;

+ (DataBase *)sharedDataBase;

//创建或打开数据库
- (void)createDataBase;

//路径
- (NSString *)pathForDataBase;

//添加新闻到数据库
- (void)addNews:(collectionModel *)newsItem;

//调用数据库
- (NSMutableArray *)display;

//清空
- (void)deleteAll;

//删除单条新闻
- (void)deleteCellOfSid: (NSString *)sid;

//查询是否已收藏
- (BOOL)queryWithSid: (NSString *)sid tableType:(NSString *)type;

//添加已读新闻ID
- (void)addNewsID:(NSString *)sid;

//查询文章是否已缓存
- (CBArticle *)articleWithSid:(NSString *)sid;

//缓存文章
- (void)cacheArticle:(CBArticle *)article;

/**
 load collection data from database to cache.
 */
- (NSArray *)starredArticleIds;



@end
