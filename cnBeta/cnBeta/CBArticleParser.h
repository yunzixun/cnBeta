//
//  CBArticleParser.h
//  cnBeta
//
//  Created by hudy on 2016/10/4.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CBArticle.h"

@interface CBArticleParser : NSObject

+ (void)parseArticle:(CBArticle *)article hpple:(TFHpple *)hpple;

@end
