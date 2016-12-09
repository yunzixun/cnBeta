//
//  CBArticle.m
//  cnBeta
//
//  Created by hudy on 2016/10/2.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "CBArticle.h"
#import "CBStarredCache.h"
#import "DYAppearanceManager.h"

@implementation CBArticle

- (BOOL)isStarred
{
    return [[CBStarredCache sharedCache] isStarred:self.newsId];
}

- (NSString *)toHTML
{
    static NSString *const kTitlePlaceholder = @"<!-- title -->";
    static NSString *const kSourcePlaceholder = @"<!-- source -->";
    static NSString *const kTimePlaceholder = @"<!-- time -->";
    static NSString *const kSummaryPlaceholder = @"<!-- summary -->";
    static NSString *const kContentPlaceholder = @"<!-- content -->";
    static NSString *const kCSSPlaceholder = @"<!-- css -->";
    static NSString *const kOriginPlaceholder = @"<!-- origin -->";
    static NSString *const kFontPlaceholder = @"<!-- myfont -->";
    
    static NSString *htmlTemplate = nil;
    
//    for (NSString *fileName in [[NSFileManager defaultManager] subpathsAtPath:[[NSBundle mainBundle]bundlePath]]) {
//        NSLog(@"%@", fileName);
//    }
    if (!htmlTemplate) {
        NSURL *htmlURL = [[NSBundle mainBundle] URLForResource:@"article" withExtension:@"html"];
        htmlTemplate = [NSString stringWithContentsOfURL:htmlURL encoding:NSUTF8StringEncoding error:nil];
    }
    
    NSString *html = htmlTemplate;
    
//    PRAppSettings *settings = [PRAppSettings sharedSettings];
    
    NSString *css;
    
//    if ([settings isNightMode]) {
//        NSURL *URL = [[NSBundle mainBundle] URLForResource:@"night" withExtension:@"css"];
//        css = [[NSString alloc] initWithContentsOfURL:URL encoding:NSUTF8StringEncoding error:nil];
//    }
//    else {
        NSURL *URL = [[NSBundle mainBundle] URLForResource:@"day" withExtension:@"css"];
        css = [[NSString alloc] initWithContentsOfURL:URL encoding:NSUTF8StringEncoding error:nil];
//    }
    
        css = [css stringByAppendingString:@"h1{font-size:20px;}.content, summary {font-size: 17px;line-height:25px;}.source, .time{font-size: 13px;}"];
    UIFont *bodyFont = [[DYAppearanceManager sharedManager] CBFont];
    css = [css stringByReplacingOccurrencesOfString:kFontPlaceholder withString:bodyFont.fontName];

    //    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
//        switch (settings.fontSize) {
//            case PRArticleFontSizeSmall:
//                css = [css stringByAppendingString:@"h1{font-size:18px;}.content, summary {font-size: 15px;line-height:22px;}.source, .time{font-size: 11px;}"];
//                break;
//            case PRArticleFontSizeNormal:
//                css = [css stringByAppendingString:@"h1{font-size:20px;}.content, summary {font-size: 17px;line-height:25px;}.source, .time{font-size: 13px;}"];
//                break;
//            case PRArticleFontSizeBig:
//                css = [css stringByAppendingString:@"h1{font-size:24px;}.content, summary {font-size: 20px;line-height:29px;}.source, .time{font-size: 15px;}"];
//                break;
//                
//            default:
//                break;
//        }
//    }
//    else {
//        switch (settings.fontSize) {
//            case PRArticleFontSizeSmall:
//                css = [css stringByAppendingString:@"h1{font-size:28px;}.content, summary {font-size: 20px;line-height:30px;}.source, .time{font-size: 15px;}"];
//                break;
//            case PRArticleFontSizeNormal:
//                css = [css stringByAppendingString:@"h1{font-size:36px;}.content, summary {font-size: 24px;line-height:36px;}.source, .time{font-size: 17px;}"];
//                break;
//            case PRArticleFontSizeBig:
//                css = [css stringByAppendingString:@"h1{font-size:44px;}.content, summary {font-size: 32px;line-height:46px;}.source, .time{font-size: 20px;}"];
//                break;
//                
//            default:
//                break;
//        }
//    }
    
//    if (settings.inclineSummary) {
//        css = [css stringByAppendingString:@"summary {font-style: italic;}"];
//    }
    
    html = [html stringByReplacingOccurrencesOfString:kCSSPlaceholder withString:css];
    if (self.title) {
        html = [html stringByReplacingOccurrencesOfString:kTitlePlaceholder withString:self.title];
    }
    if (self.author) {
        html = [html stringByReplacingOccurrencesOfString:kSourcePlaceholder withString:[NSString stringWithFormat:@"责编：%@", self.author]];
    }
    if (self.pubTime) {
        html = [html stringByReplacingOccurrencesOfString:kTimePlaceholder withString:self.pubTime];
    }
    if (self.summary) {
        NSString *htmlString = [NSString stringWithFormat:@"<font face='%@' >%@", bodyFont.fontName,self.summary];
        html = [html stringByReplacingOccurrencesOfString:kSummaryPlaceholder withString:htmlString];
    }
    if (self.content) {
        NSString *htmlString = [NSString stringWithFormat:@"<font face='%@' >%@", bodyFont.fontName,self.content];
        html = [html stringByReplacingOccurrencesOfString:kContentPlaceholder withString:htmlString];
        
        
//        if (settings.isImageWIFIOnly && ![[AFNetworkReachabilityManager sharedManager] isReachableViaWiFi]) {
//            for (NSString *imgSrc in self.imgSrcs) {
//                html = [html stringByReplacingOccurrencesOfString:imgSrc withString:[@"plainreader://article.body.img?" stringByAppendingString:imgSrc]];
//            }
//        }
    }

//    NSRange startRange = [html rangeOfString:@"<iframe"];
//    if(startRange.location!=NSNotFound){
//        html = [html substringToIndex:startRange.location];
//    }
    
    html = [html stringByReplacingOccurrencesOfString:kOriginPlaceholder withString:[NSString stringWithFormat:@"http://www.cnbeta.com/articles/%@.htm", self.newsId]];
    return html;

}
@end
