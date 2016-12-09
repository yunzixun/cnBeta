//
//  CBFormatedSQLGenerator.h
//  cnBeta
//
//  Created by hudy on 2016/10/5.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CBArticle.h"

@interface CBFormatedSQLGenerator : NSObject

+ (void)generateSQLForArticle:(CBArticle *)article completion: (void (^)(NSString * sql, NSArray *arguments))completionBlock;

@end
