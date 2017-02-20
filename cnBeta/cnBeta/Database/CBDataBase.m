//
//  CBDataBase.m
//  cnBeta
//
//  Created by hudy on 2016/10/4.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "CBDataBase.h"
#import "FMDB.h"
#import "CBFormatedSQLGenerator.h"

@interface CBDataBase ()

@property (nonatomic, strong) FMDatabaseQueue *dbQueue;

@end

@implementation CBDataBase


+ (instancetype)sharedDataBase
{
    static CBDataBase *dataBase = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dataBase = [[CBDataBase alloc] init];
    });
    return dataBase;
}

- (void)prepareDataBase
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *databasePath = [self pathForDataBase];
        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:databasePath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL success = [fileManager fileExistsAtPath:databasePath];
        if (success){
            [_dbQueue inDatabase:^(FMDatabase *db) {
                BOOL result1 = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS articleCache (newsId INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, title TEXT, source TEXT, summary TEXT, pubTime TEXT, content TEXT, sn TEXT);"];
                BOOL result2 = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS newsListCache (newsId INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, title TEXT, pubTime TEXT, comments TEXT, thumb TEXT, author TEXT, read INTEGER);"];
                BOOL result3 = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS collection (newsId INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, title TEXT, date TEXT, thumb TEXT);"];
                if (!result1 || !result2 || !result3) {
                    NSLog(@"%@", [db lastErrorMessage]);
                }
                if (![db columnExists:@"hometext" inTableWithName:@"newsListCache"]) {
                    NSString *alertStr = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ INTEGER",@"newsListCache",@"hometext"];
                    BOOL worked = [db executeUpdate:alertStr];
                    if(worked){
                        NSLog(@"插入成功");
                    }else{
                        NSLog(@"插入失败");
                    }
                }
            }];
        }
    });
}



- (NSString *)pathForDataBase
{
    static NSString *dbPath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDir = [paths objectAtIndex:0];
        dbPath = [documentDir stringByAppendingPathComponent:@"cnbeta.db"];
    });
    return dbPath;
}

//查询已缓存文章
- (CBArticle *)articleWithSid:(NSString *)sid
{
    __block CBArticle *article = [[CBArticle alloc] init];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *set = [db executeQuery:@"SELECT * FROM articleCache WHERE newsId = ?", sid];
        while ([set next]) {
            article.newsId = [NSString stringWithFormat: @"%@", [set objectForColumnName:@"newsId"]];
            article.title = [set stringForColumn:@"title"];
            article.source = [set stringForColumn:@"source"];
            article.summary = [set stringForColumn:@"summary"];
            article.pubTime = [set stringForColumn:@"pubTime"];
            article.content = [set stringForColumn:@"content"];
            article.sn = [set stringForColumn:@"sn"];
        }
    }];
    return article;
}

- (BOOL)isCached:(NSString *)sid
{
    __block NSInteger count = 0;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        count = [db intForQuery:@"SELECT COUNT (newsId) FROM articleCache WHERE newsId = ?", sid];
    }];
    if (count > 0) {
        return YES;
    } else {
        return NO;
    }
}

//缓存文章
- (void)cacheArticle:(CBArticle *)article
{
    if (!article.title) {
        return;
    }
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSInteger count = [db intForQuery:@"SELECT COUNT (newsId) FROM articleCache WHERE newsId = ?", article.newsId];
        if (count == 0) {
            [CBFormatedSQLGenerator generateSQLForInsertingArticle:article completion:^(NSString *sql, NSArray *arguments) {
                BOOL result = [db executeUpdate:sql withArgumentsInArray:arguments];
                if (!result) {
                    NSLog(@"%@", [db lastErrorMessage]);
                }
            }];
        } else {
            [CBFormatedSQLGenerator generateSQLForUpdatingArticle:article completion:^(NSString *sql, NSArray *arguments) {
                BOOL result = [db executeUpdate:sql withArgumentsInArray:arguments];
                if (!result) {
                    NSLog(@"%@", [db lastErrorMessage]);
                }
            }];
        }
        
    }];
}

- (void)starArticle:(collectionModel *)newsItem
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSInteger count = [db intForQuery:@"SELECT COUNT (newsId) FROM collection WHERE newsId = ?", newsItem.sid];
        if (count == 0) {
            BOOL result = [db executeUpdate:@"INSERT OR REPLACE INTO collection (newsId, title, date, thumb) VALUES (?, ?, ?, ?)", @([newsItem.sid intValue]), newsItem.title, newsItem.time, newsItem.thumb];
            if (!result) {
                NSLog(@"%@", [db lastErrorMessage]);
            }
        }
    }];
}

- (void)unstarArticle:(collectionModel *)newsItem
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        BOOL result = [db executeUpdate:@"DELETE FROM collection WHERE newsId = ?", @([newsItem.sid intValue])];
        if (!result) {
            NSLog(@"%@", [db lastErrorMessage]);
        }
    }];
}

- (NSMutableArray *)starredArticles
{
    NSMutableArray *articles = [[NSMutableArray alloc] init];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *set = [db executeQuery:@"SELECT * FROM collection"];
        while ([set next]) {
            collectionModel *item = [[collectionModel alloc] init];
            item.sid = [NSString stringWithFormat:@"%@", [set objectForColumnName:@"newsId"]];
            item.title = [set stringForColumn:@"title"];
            item.time = [set stringForColumn:@"date"];
            item.thumb = [set stringForColumn:@"thumb"];
            [articles addObject:item];
        }
    }];
    return articles;
}

- (NSArray *)starredArticleIds
{
    NSMutableArray *starredArticleIds = [[NSMutableArray alloc]init];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *set = [db executeQuery:@"SELECT * FROM collection"];
        while ([set next]) {
            NSString *newsId = [NSString stringWithFormat:@"%@", [set objectForColumnName:@"newsId"]];
            [starredArticleIds addObject:newsId];
        }
    }];

    return starredArticleIds;
}


- (void)deleteAllStarred
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        BOOL result = [db executeUpdate:@"DELETE FROM collection"];
        if (!result) {
            NSLog(@"%@", [db lastErrorMessage]);
        }
    }];
}

//查询已缓存列表新闻
- (NewsModel *)newsWithSid:(NSString *)sid
{
    __block NewsModel *news = [[NewsModel alloc] init];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *set = [db executeQuery:@"SELECT * FROM newsListCache WHERE newsId = ?", sid];
        while ([set next]) {
            news.sid = [NSString stringWithFormat:@"%@", [set objectForColumnName:@"newsId"]];
            news.title = [set stringForColumn:@"title"];
            news.inputtime = [set stringForColumn:@"pubTime"];
            news.comments = [set stringForColumn:@"comments"];
            news.thumb = [set stringForColumn:@"thumb"];
            news.aid = [set stringForColumn:@"author"];
            news.read = [set objectForColumnName:@"read"];
            if ([news.read isKindOfClass:[NSNull class]]) {
                news.read = nil;
            }
            news.hometext = [set stringForColumn:@"hometext"];
            if ([news.hometext isKindOfClass:[NSNull class]]) {
                news.hometext = nil;
            }
        }
    }];
    return news;
}

//缓存列表新闻
- (void)cacheNews:(NewsModel *)news
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSInteger count = [db intForQuery:@"SELECT COUNT (newsId) FROM newsListCache WHERE newsId = ?", news.sid];
        if (count==0) {
            [CBFormatedSQLGenerator generateSQLForInsertingListNews:news completion:^(NSString *sql, NSArray *arguments) {
                BOOL result = [db executeUpdate:sql withArgumentsInArray:arguments];
                if (!result) {
                    NSLog(@"%@", [db lastErrorMessage]);
                }
            }];
        } else {
            [CBFormatedSQLGenerator generateSQLForUpdatingListNews:news completion:^(NSString *sql, NSArray *arguments) {
                BOOL result = [db executeUpdate:sql withArgumentsInArray:arguments];
                if (!result) {
                    NSLog(@"%@", [db lastErrorMessage]);
                }
            }];

        }
    }];
}

- (void)updateReadField:(NewsModel *)news
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"UPDATE newsListCache SET read = ? WHERE newsId = ?", news.read, news.sid];
    }];
}

- (NSArray *)newsListWithLastNews:(NewsModel *)lastNews limit:(NSInteger)limit
{
    NSString *sql = nil;
    if (lastNews) {
        sql = [NSString stringWithFormat:@"SELECT newsId, title, pubTime, comments, thumb, author, read, hometext FROM newsListCache WHERE newsId < %@ AND (pubTime IS NOT NULL OR pubtime != '') ORDER BY newsId DESC LIMIT %@", lastNews.sid, [@(limit) stringValue]];

    } else {
        sql = [NSString stringWithFormat:@"SELECT newsId, title, pubTime, comments, thumb, author, read, hometext FROM newsListCache WHERE (pubTime IS NOT NULL OR pubtime != '') ORDER BY newsId DESC LIMIT %@", [@(limit) stringValue]];

    }
    NSMutableArray *newsList = [[NSMutableArray alloc] init];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *set = [db executeQuery:sql];
        while ([set next]) {
            NewsModel *news = [[NewsModel alloc] init];
            news.sid = [NSString stringWithFormat:@"%@", [set objectForColumnName:@"newsId"]];
            news.title = [set stringForColumn:@"title"];
            news.inputtime = [set stringForColumn:@"pubTime"];
            news.comments = [set stringForColumn:@"comments"];
            news.thumb = [set stringForColumn:@"thumb"];
            news.aid = [set stringForColumn:@"author"];
            news.read = [set objectForColumnName:@"read"];
            if ([news.read isKindOfClass:[NSNull class]]) {
                news.read = nil;
            }
            news.hometext = [set stringForColumn:@"hometext"];
            if ([news.hometext isKindOfClass:[NSNull class]]) {
                news.hometext = nil;
            }
            [newsList addObject:news];
        }
    }];
    return newsList;
}

- (void)clearExpiredCache
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSDate *aWeekAgo = [NSDate dateWithTimeIntervalSinceNow:-(7*60*60*24)];
        NSTimeInterval interval = [aWeekAgo timeIntervalSince1970];
        BOOL result1 = [db executeUpdate:
                        @"DELETE FROM articleCache WHERE pubTime <= Datetime(?, 'unixepoch', 'localtime')"
                        "AND newsId NOT IN (SELECT newsId FROM collection)", @(interval)];
        if (!result1) {
            NSLog(@"%@", [db lastErrorMessage]);
        }

        BOOL result2 = [db executeUpdate:@"DELETE FROM newsListCache WHERE pubTime <= Datetime(?, 'unixepoch', 'localtime')", @(interval)];
        if (!result2) {
            NSLog(@"%@", [db lastErrorMessage]);
        }
    }];
}



@end
