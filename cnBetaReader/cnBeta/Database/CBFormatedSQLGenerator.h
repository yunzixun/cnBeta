//
//  CBFormatedSQLGenerator.h
//  cnBeta
//
//  Created by hudy on 2016/10/5.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CBArticle.h"
#import "NewsModel.h"

@interface CBFormatedSQLGenerator : NSObject
/**
 *  generate SQL for news article with a completion block
 *
 *  @param article         article model
 *  @param completionBlock block for sql execution 
 */
+ (void)generateSQLForInsertingArticle:(CBArticle *)article completion: (void (^)(NSString * sql, NSArray *arguments))completionBlock;

+ (void)generateSQLForUpdatingArticle:(CBArticle *)article completion: (void (^)(NSString * sql, NSArray *arguments))completionBlock;

+ (void)generateSQLForInsertingListNews:(NewsModel *)news completion: (void (^)(NSString * sql, NSArray *arguments))completionBlock;

+ (void)generateSQLForUpdatingListNews:(NewsModel *)news completion: (void (^)(NSString * sql, NSArray *arguments))completionBlock;


@end
