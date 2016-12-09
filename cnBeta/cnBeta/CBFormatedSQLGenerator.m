//
//  CBFormatedSQLGenerator.m
//  cnBeta
//
//  Created by hudy on 2016/10/5.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "CBFormatedSQLGenerator.h"

@implementation CBFormatedSQLGenerator

+ (void)generateSQLForArticle:(CBArticle *)article completion: (void (^)(NSString * sql, NSArray *arguments))completionBlock
{
    NSMutableArray *columns = [[NSMutableArray alloc] init];
    NSMutableArray *placeHolders = [[NSMutableArray alloc]init];
    NSMutableArray *arguments = [[NSMutableArray alloc] init];
    
    [columns addObject:@"newsId"];
    [placeHolders addObject:@"?"];
    [arguments addObject:@([article.newsId intValue])];
    
    [columns addObject:@"title"];
    [placeHolders addObject:@"?"];
    [arguments addObject:article.title];
    
    [columns addObject:@"source"];
    [placeHolders addObject:@"?"];
    [arguments addObject:article.source];
    
    [columns addObject:@"pubTime"];
    [placeHolders addObject:@"?"];
    [arguments addObject:article.pubTime];
    
    [columns addObject:@"summary"];
    [placeHolders addObject:@"?"];
    [arguments addObject:article.summary];
    
    [columns addObject:@"content"];
    [placeHolders addObject:@"?"];
    [arguments addObject:article.content];
    
    [columns addObject:@"sn"];
    [placeHolders addObject:@"?"];
    [arguments addObject:article.sn];

    NSString *sql = [NSString stringWithFormat:@"INSERT INTO articleCache (%@) VALUES(%@)", [columns componentsJoinedByString:@","], [placeHolders componentsJoinedByString:@","]];
    completionBlock(sql, arguments);
}

@end
