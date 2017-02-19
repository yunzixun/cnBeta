//
//  CBArticle.m
//  cnBeta
//
//  Created by hudy on 2016/10/2.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "CBArticle.h"
#import "CBStarredCache.h"
#import "CBAppearanceManager.h"
#import "CBAppSettings.h"


NSString *const XPathQueryArticleImages = @"//div[@class=\"content\"]//img";

@interface CBArticle ()

@property (nonatomic, strong)NSArray *imageUrls;

@end

@implementation CBArticle

- (BOOL)isStarred
{
    return [[CBStarredCache sharedCache] isStarred:self.newsId];
}

- (NSArray *)imageUrls
{
    if (!self.content) {
        return nil;
    }
    if (!_imageUrls) {
        NSData *contentData = [self.content dataUsingEncoding:NSUTF8StringEncoding];
        TFHpple *hpple = [[TFHpple alloc] initWithHTMLData:contentData];
        NSArray *images = [hpple searchWithXPathQuery:XPathQueryArticleImages];
        NSMutableArray *imgSrcs = [[NSMutableArray alloc] init];
        
        for (TFHppleElement *img in images) {
            [imgSrcs addObject:[img objectForKey:@"src"]];
        }
        _imageUrls = imgSrcs;
    }
    return  _imageUrls;
}

- (NSString *)toHTML
{
    static NSString *const kTitlePlaceholder = @"<!-- title -->";
    static NSString *const kSourcePlaceholder = @"<!-- source -->";
    static NSString *const kEditorPlaceholder = @"<!-- editor -->";
    static NSString *const kTimePlaceholder = @"<!-- time -->";
    static NSString *const kSummaryPlaceholder = @"<!-- summary -->";
    static NSString *const kContentPlaceholder = @"<!-- content -->";
    static NSString *const kCSSPlaceholder = @"<!-- css -->";
    static NSString *const kOriginPlaceholder = @"<!-- origin -->";
    //static NSString *const kFontPlaceholder = @"<!-- myfont -->";
    
    static NSString *htmlTemplate = nil;
    
//    for (NSString *fileName in [[NSFileManager defaultManager] subpathsAtPath:[[NSBundle mainBundle]bundlePath]]) {
//        NSLog(@"%@", fileName);
//    }
    if (!htmlTemplate) {
        NSURL *htmlURL = [[NSBundle mainBundle] URLForResource:@"article" withExtension:@"html"];
        htmlTemplate = [NSString stringWithContentsOfURL:htmlURL encoding:NSUTF8StringEncoding error:nil];
    }
    
    NSString *html = htmlTemplate;
    
    
    NSString *css;
    NSString *summaryBackground;
    if ([CBAppSettings sharedSettings].isNightMode) {
        NSURL *URL = [[NSBundle mainBundle] URLForResource:@"night" withExtension:@"css"];
        css = [[NSString alloc] initWithContentsOfURL:URL encoding:NSUTF8StringEncoding error:nil];
        summaryBackground = @"<summary style=\"background: #464646\">";
    }
    else {
        NSURL *URL = [[NSBundle mainBundle] URLForResource:@"day" withExtension:@"css"];
        css = [[NSString alloc] initWithContentsOfURL:URL encoding:NSUTF8StringEncoding error:nil];
        summaryBackground = @"<summary style=\"background: #F0F0F0\">";
    }
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        css = [css stringByAppendingString:@"h1{font-size:20px;}.content, summary {font-size: 17px;line-height:25px;}.source, .editor, .time{font-size: 11px;}"];
    } else {
        css = [css stringByAppendingString:@"h1{font-size:25px;}.content, summary {font-size: 20px;line-height:30px;}.source, .editor, .time{font-size: 15px;}"];
    }
    
    UIFont *bodyFont = [[CBAppearanceManager sharedManager] CBFont];
//    css = [css stringByReplacingOccurrencesOfString:kFontPlaceholder withString:bodyFont.fontName];

    
    html = [html stringByReplacingOccurrencesOfString:kCSSPlaceholder withString:css];
    if (self.title) {
        html = [html stringByReplacingOccurrencesOfString:kTitlePlaceholder withString:self.title];
    }
    if (self.source && [CBAppSettings sharedSettings].sourceDisplayEnabled) {
        html = [html stringByReplacingOccurrencesOfString:kSourcePlaceholder withString:self.source];
    }
    if (self.author) {
        html = [html stringByReplacingOccurrencesOfString:kEditorPlaceholder withString:[NSString stringWithFormat:@"责编：%@", self.author]];
    }
    if (self.pubTime) {
        html = [html stringByReplacingOccurrencesOfString:kTimePlaceholder withString:self.pubTime];
    }
    if (self.summary) {
        NSString *htmlString = [summaryBackground stringByAppendingString:[NSString stringWithFormat:@"<font face='%@' >%@", bodyFont.fontName,self.summary]];
        html = [html stringByReplacingOccurrencesOfString:kSummaryPlaceholder withString:htmlString];
    }
    if (self.content) {
        NSRange range = [self.content rangeOfString:@"[广告]"];
        NSString *htmlString = [NSString stringWithFormat:@"<font face='%@' >%@", bodyFont.fontName,[self.content substringToIndex:range.location]];
        html = [html stringByReplacingOccurrencesOfString:kContentPlaceholder withString:htmlString];
   
        if ([CBAppSettings sharedSettings].imageWiFiOnlyEnabled && ![[AFNetworkReachabilityManager sharedManager] isReachableViaWiFi]) {
            html = [html stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
            for (NSString *imgSrc in self.imageUrls) {
                html = [html stringByReplacingOccurrencesOfString:imgSrc
                                                       withString:[@"cnbeta://article.body.img?" stringByAppendingString:imgSrc]];
            }
        }
    }

    html = [html stringByReplacingOccurrencesOfString:@"<strong>" withString:@"<b>"];
    html = [html stringByReplacingOccurrencesOfString:@"</strong>" withString:@"</b>"];

    html = [html stringByReplacingOccurrencesOfString:kOriginPlaceholder withString:[NSString stringWithFormat:@"http://www.cnbeta.com/articles/%@.htm", self.newsId]];
    return html;

}
@end
