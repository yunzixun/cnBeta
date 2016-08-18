//
//  DataBase.m
//  cnBeta
//
//  Created by hudy on 16/7/8.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "DataBase.h"
#import "collectionModel.h"


@implementation DataBase

+ (DataBase *)sharedDataBase
{
    static DataBase *dataBase = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dataBase = [[DataBase alloc]init];
    });
    return dataBase;
}

- (id)init
{
    if (self = [super init]) {
        ioQueue = dispatch_queue_create("sqlActions", DISPATCH_QUEUE_SERIAL);
        
    }
    return self;
}


- (void)createDataBase
{
    NSString *databasePath = [self pathForDataBase];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL success = [fileManager fileExistsAtPath:databasePath];
    if (!success) {
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database)==SQLITE_OK) {
            char *errmsg;
            const char *createsql = "CREATE TABLE IF NOT EXISTS collection (sid INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, title TEXT, time TEXT, thumb TEXT)";
            if (sqlite3_exec(database, createsql, NULL, NULL, &errmsg) != SQLITE_OK) {
                NSLog(@"create table failed.");
            }
            const char *createsql2 = "CREATE TABLE IF NOT EXISTS newsID (sid INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT)";
            if (sqlite3_exec(database, createsql2, NULL, NULL, &errmsg) != SQLITE_OK) {
                NSLog(@"create table failed.");
            }
        }else
        {
            // 打开数据库失败
            NSAssert1(0, @"Failed to open database: '%s'.", sqlite3_errmsg(database));
        }
        sqlite3_close(database);
    }

}

- (NSString *)pathForDataBase
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [paths objectAtIndex:0];
    return [documentDir stringByAppendingPathComponent:@"collection.db"];

}


//添加新闻到数据库
- (void)addNews:(collectionModel *)newsItem
{
    sqlite3_stmt *statement;
    const char *dbpath = [[self pathForDataBase]UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSString *insertItem = [NSString stringWithFormat:@"INSERT INTO collection (sid,title,time,thumb) VALUES(\"%@\",\"%@\",\"%@\",\"%@\")", newsItem.sid, newsItem.title, newsItem.time, newsItem.thumb];
        const char *insertStatement =[insertItem UTF8String];
        int insertReault = sqlite3_prepare_v2(database, insertStatement, -1, &statement, NULL);
        if (insertReault == SQLITE_OK) {
            sqlite3_step(statement);
        }else {
            NSLog(@"收藏失败");
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    
    
}

//调用数据库
- (NSMutableArray *)display
{
    NSMutableArray *newsArray = [[NSMutableArray alloc]init];
    
    sqlite3_stmt *statement;
    const char *dbpath = [[self pathForDataBase]UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        const char *selectStatement = "SELECT * FROM collection";
        int selectResult = sqlite3_prepare_v2(database, selectStatement, -1, &statement, NULL);
        if (selectResult == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                collectionModel *newsItem = [[collectionModel alloc]init];
                
                int sid = sqlite3_column_int(statement, 0);
                const char *title = (char *)sqlite3_column_text(statement, 1);
                const char *time = (char *)sqlite3_column_text(statement, 2);
                const char *thumb = (char *)sqlite3_column_text(statement, 3);
                
                newsItem.sid = [NSString stringWithFormat:@"%d", sid];
                newsItem.title = [NSString stringWithUTF8String:title];
                newsItem.time = [NSString stringWithUTF8String:time];
                newsItem.thumb = [NSString stringWithUTF8String:thumb];
                [newsArray addObject:newsItem];
            }
            
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    return newsArray;
}

//清空
- (void)deleteAll
{
    dispatch_async(ioQueue, ^{
        sqlite3_stmt *statement;
        const char *dbpath = [[self pathForDataBase]UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
            const char *deleteStatement = "DELETE FROM collection";
            int deleteResult = sqlite3_prepare_v2(database, deleteStatement, -1, &statement, NULL);
            if (deleteResult == SQLITE_OK) {
                sqlite3_step(statement);
            }
            sqlite3_finalize(statement);
            sqlite3_close(database);
        }
    });

}

//删除单条新闻
- (void)deleteCellOfSid: (NSString *)sid
{
    sqlite3_stmt *statement;
    const char *dbpath = [[self pathForDataBase]UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSString *deleteCell = [NSString stringWithFormat:@"DELETE FROM collection WHERE sid = %@", sid];
        const char *deleteStatement = [deleteCell UTF8String];
        int deleteResult = sqlite3_prepare_v2(database, deleteStatement, -1, &statement, NULL);
        if (deleteResult == SQLITE_OK) {
            sqlite3_step(statement);
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
}

//查询是否已收藏
- (BOOL)queryWithSid: (NSString *)sid tableType:(NSString *)type
{
    BOOL isExisted = NO;
    sqlite3_stmt *statement;
    const char *dbpath = [[self pathForDataBase]UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSString *query;
        if ([type isEqualToString:@"collection"]) {
            query = [NSString stringWithFormat:@"SELECT * FROM collection WHERE sid = %@", sid];
        } else {
            query = [NSString stringWithFormat:@"SELECT * FROM newsID WHERE sid = %@", sid];
        }
        const char *queryStatement = [query UTF8String];
        int queryResult = sqlite3_prepare_v2(database, queryStatement, -1, &statement, NULL);
        if (queryResult == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                isExisted = YES;
            }
        }else {
            NSLog(@"查询失败");
        }
        
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    return isExisted;
    
}

//添加已读新闻ID
- (void)addNewsID:(NSString *)sid
{
    sqlite3_stmt *statement;
    const char *dbpath = [[self pathForDataBase]UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSString *insertItem = [NSString stringWithFormat:@"INSERT INTO newsID (sid) VALUES(\"%@\")", sid ];
        const char *insertStatement = [insertItem UTF8String];
        int insertResult = sqlite3_prepare_v2(database, insertStatement, -1, &statement, NULL);
        if (insertResult == SQLITE_OK) {
            sqlite3_step(statement);
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
}


@end
