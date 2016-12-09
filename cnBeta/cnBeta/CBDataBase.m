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
                BOOL result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS articleCache (newsId INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, title TEXT, source TEXT, summary TEXT, pubTime TEXT, content TEXT, sn TEXT);"];
                if (!result) {
                    NSLog(@"%@", [db lastErrorMessage]);
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

//缓存文章
- (void)cacheArticle:(CBArticle *)article
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [CBFormatedSQLGenerator generateSQLForArticle:article completion:^(NSString *sql, NSArray *arguments) {
            BOOL result = [db executeUpdate:sql withArgumentsInArray:arguments];
            if (!result) {
                NSLog(@"%@", [db lastErrorMessage]);
            }
        }];
    }];
}

- (void)clearExpiredCache
{
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSDate *aWeekAgo = [NSDate dateWithTimeIntervalSinceNow:-(7*60*60*24)];
        NSTimeInterval interval = [aWeekAgo timeIntervalSince1970];
        BOOL result = [db executeUpdate:@"DELETE FROM articleCache WHERE pubTime <= Datetime(?, 'unixepoch', 'localtime')", @(interval)];
        if (!result) {
            NSLog(@"%@", [db lastErrorMessage]);
        }
    }];
}



@end
