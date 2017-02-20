//
//  CBFormatedSQLGenerator.m
//  cnBeta
//
//  Created by hudy on 2016/10/5.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "CBFormatedSQLGenerator.h"
#import "NSString+removehtml.h"

@implementation CBFormatedSQLGenerator

+ (void)generateSQLForInsertingArticle:(CBArticle *)article completion: (void (^)(NSString * sql, NSArray *arguments))completionBlock
{
    NSMutableArray *columns = [[NSMutableArray alloc] init];
    NSMutableArray *placeHolders = [[NSMutableArray alloc]init];
    NSMutableArray *arguments = [[NSMutableArray alloc] init];
    
    if (article.newsId) {
        [columns addObject:@"newsId"];
        [placeHolders addObject:@"?"];
        [arguments addObject:@([article.newsId intValue])];
    }

    if (article.title) {
        [columns addObject:@"title"];
        [placeHolders addObject:@"?"];
        [arguments addObject:article.title];
    }
    
    if (article.source) {
        [columns addObject:@"source"];
        [placeHolders addObject:@"?"];
        [arguments addObject:article.source];
    }
    
    if (article.pubTime) {
        [columns addObject:@"pubTime"];
        [placeHolders addObject:@"?"];
        [arguments addObject:article.pubTime];
    }
    
    if (article.summary) {
        [columns addObject:@"summary"];
        [placeHolders addObject:@"?"];
        [arguments addObject:article.summary];
    }
    
    if (article.content) {
        [columns addObject:@"content"];
        [placeHolders addObject:@"?"];
        [arguments addObject:article.content];
    }

    if (article.sn) {
        [columns addObject:@"sn"];
        [placeHolders addObject:@"?"];
        [arguments addObject:article.sn];
    }


    NSString *sql = [NSString stringWithFormat:@"INSERT INTO articleCache (%@) VALUES(%@)", [columns componentsJoinedByString:@","], [placeHolders componentsJoinedByString:@","]];
    completionBlock(sql, arguments);
}

+ (void)generateSQLForUpdatingArticle:(CBArticle *)article completion: (void (^)(NSString * sql, NSArray *arguments))completionBlock
{
    NSMutableArray *columns = [[NSMutableArray alloc] init];
    NSMutableArray *arguments = [[NSMutableArray alloc] init];
    
    if (article.summary) {
        [columns addObject:@"summary = ?"];
        [arguments addObject:article.summary];
    }
    
    if (article.content) {
        [columns addObject:@"content = ?"];
        [arguments addObject:article.content];
    }
    
    NSString *sql = [NSString stringWithFormat:@"UPDATE articleCache SET %@ WHERE newsId = %@", [columns componentsJoinedByString:@","], article.newsId];
    completionBlock(sql, arguments);
}

+ (void)generateSQLForInsertingListNews:(NewsModel *)news completion: (void (^)(NSString * sql, NSArray *arguments))completionBlock
{
    NSMutableArray *columns = [[NSMutableArray alloc] init];
    NSMutableArray *placeHolders = [[NSMutableArray alloc]init];
    NSMutableArray *arguments = [[NSMutableArray alloc] init];
    
    if (news.sid) {
        [columns addObject:@"newsId"];
        [placeHolders addObject:@"?"];
        [arguments addObject:@([news.sid intValue])];
        
    }

    if (news.title) {
        [columns addObject:@"title"];
        [placeHolders addObject:@"?"];
        [arguments addObject:news.title];
    }
    
    if (news.inputtime) {
        [columns addObject:@"pubTime"];
        [placeHolders addObject:@"?"];
        [arguments addObject:news.inputtime];
    }
    
    if (news.comments) {
        [columns addObject:@"comments"];
        [placeHolders addObject:@"?"];
        [arguments addObject:news.comments];
    }

    if (news.thumb) {
        [columns addObject:@"thumb"];
        [placeHolders addObject:@"?"];
        [arguments addObject:news.thumb];
    }

    if (news.aid) {
        [columns addObject:@"author"];
        [placeHolders addObject:@"?"];
        [arguments addObject:news.aid];
    }

    
    if (news.read) {
        [columns addObject:@"read"];
        [placeHolders addObject:@"?"];
        [arguments addObject:news.read];
    }

    if (isPad) {
        if (news.hometext) {
            [columns addObject:@"hometext"];
            [placeHolders addObject:@"?"];
            [arguments addObject:[news.hometext removeHTML]];
        }
    }

    NSString *sql = [NSString stringWithFormat:@"INSERT INTO newsListCache (%@) VALUES(%@)", [columns componentsJoinedByString:@","], [placeHolders componentsJoinedByString:@","]];
    completionBlock(sql, arguments);

}

+ (void)generateSQLForUpdatingListNews:(NewsModel *)news completion: (void (^)(NSString * sql, NSArray *arguments))completionBlock
{
    NSMutableArray *columns = [[NSMutableArray alloc] init];
    NSMutableArray *arguments = [[NSMutableArray alloc] init];
    
    if (news.comments) {
        [columns addObject:@"comments = ?"];
        [arguments addObject:news.comments];
    }

    NSString *sql = [NSString stringWithFormat:@"UPDATE newsListCache SET %@ WHERE newsId = %@", [columns componentsJoinedByString:@","], news.sid];
    completionBlock(sql, arguments);
}


@end
