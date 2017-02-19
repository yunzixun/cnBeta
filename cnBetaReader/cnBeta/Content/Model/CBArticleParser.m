//
//  CBArticleParser.m
//  cnBeta
//
//  Created by hudy on 2016/10/4.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "CBArticleParser.h"


@implementation CBArticleParser

+ (void)parseArticle:(CBArticle *)article hpple:(TFHpple *)hpple
{
    if (!article.title) {
        TFHppleElement *titleElement = [[hpple searchWithXPathQuery:@"//h2[@id=\"news_title\"]"] firstObject];
        article.title = [titleElement text];
    }
    // 时间
    if (!article.pubTime) {
        TFHppleElement *timeElement = [[hpple searchWithXPathQuery:@"//span[@class=\"date\"]"] firstObject];
        article.pubTime = [timeElement text];
    }
    
    // 来源
    TFHppleElement *sourceElement = [[hpple searchWithXPathQuery:@"//span[@class=\"where\"]/a"] firstObject];
    if (!sourceElement) {
        sourceElement = [[hpple searchWithXPathQuery:@"//span[@class=\"where\"]"] firstObject];
    }
    article.source = sourceElement.text;
    
    // 摘要
    NSArray *elements = [hpple searchWithXPathQuery:@"//div[@class=\"introduction\"]/p"];
    TFHppleElement *summaryElement = [elements objectAtIndex:0];
    NSMutableString *summary = [summaryElement.raw mutableCopy];
    if (elements.count > 1) {
        TFHppleElement *summaryElement2 = [elements objectAtIndex:1];
        NSString *summary2 = summaryElement2.raw;
        if (![summary2 isEqualToString:@"<p><br /></p>"]) {
            [summary appendString:summary2];
        }
    }
    article.summary = summary;
    
    // 内容
    TFHppleElement *contentElement = [[hpple searchWithXPathQuery:@"//div[@class=\"content\"]"] firstObject];
    NSString *content = [contentElement raw];
    if (content) {
        // 去除内联样式
        NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:@" style=\"[^\"]*\"" options:NSRegularExpressionCaseInsensitive error:nil];
        content = [reg stringByReplacingMatchesInString:content options:kNilOptions range:NSMakeRange(0, [content length]) withTemplate:@""];
        article.content = content;
    }
    
    // sn
    NSString *wholeHTML = [[NSString alloc] initWithData:hpple.data encoding:NSUTF8StringEncoding];
    if (wholeHTML) {
        NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:@"SN:\"([^\"]*)\"" options:NSRegularExpressionCaseInsensitive error:nil];
        NSTextCheckingResult *match = [reg firstMatchInString:wholeHTML options:0 range:NSMakeRange(0, [wholeHTML length])];
        if ([match numberOfRanges] > 0) {
            NSString *sn = [wholeHTML substringWithRange:[match rangeAtIndex:1]];
            article.sn = sn;
        }
    }

}

@end
