//
//  contentViewController.m
//  cnBeta
//
//  Created by hudy on 16/6/22.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "contentViewController.h"
#import "UIViewController+DownloadNews.h"
#import "NSString+MD5.h"
#import "HTMLCache.h"

static NSString *const contentBaseURLString = @"http://api.cnbeta.com/capi?app_key=10000&format=json&method=Article.NewsContent&sid=";

@interface contentViewController ()
@property (nonatomic, strong)NSString *contentHTMLString;
@property (nonatomic, strong)NSString *contentURL;
@end

@implementation contentViewController


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [_spinner startAnimating];
    [self setupWebView];
}

- (void)setupWebView
{
    
        HTMLCache *htmlCache = [HTMLCache sharedCache];
        _contentHTMLString = [htmlCache getHTMLFromFileForKey:self.newsId];
        if (!_contentHTMLString) {
            //Unix时间戳
            UInt64 timestamp = (UInt64)[[NSDate date]timeIntervalSince1970];
            
            //md5加密
            NSString *md5String = [NSString stringWithFormat:@"app_key=10000&format=json&method=Article.NewsContent&sid=%@&timestamp=%llu&v=1.0&mpuffgvbvbttn3Rc", self.newsId, timestamp ];
            NSString *sign = [md5String MD5];
            
            self.contentURL = [contentBaseURLString stringByAppendingString:[NSString stringWithFormat:@"%@&timestamp=%llu&v=1.0&mpuffgvbvbttn3Rc&sign=%@", self.newsId, timestamp, sign]];
            
            [self startDownloadContent];
            
        } else{
            [_contentWebView loadHTMLString:_contentHTMLString baseURL:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_spinner stopAnimating];
                //[_spinner removeFromSuperview];
                //_spinner.hidden = YES;
            });
        }
    

    
}

- (void)startDownloadContent
{
    if (self.contentURL) {
        
        [self requestWithURL:self.contentURL completion:^(NSData *data, NSError *error) {
            if (!error) {
                NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil][@"result"];
                
                [self getHTMLByData:dataDic];
                //缓存到文件系统
                HTMLCache *htmlCache = [HTMLCache sharedCache];
                [htmlCache cacheHTMLToFile:_contentHTMLString forKey:_newsId];
            }
            //NSLog(@"%@",dic);
        }];
    }
}

- (void)getHTMLByData:(id)data
{
    
    NSDictionary *dataDic = (NSDictionary *)data;
    self.newsTitle = dataDic[@"title"];
    self.homeText = dataDic[@"hometext"];
    self.bodyText = dataDic[@"bodytext"];
    self.source = dataDic[@"source"];
    self.time = dataDic[@"time"];
    
    NSMutableString *allTitleStr =[NSMutableString stringWithString:@"<style type='text/css'> p.thicker{font-weight: 500}p.light{font-weight: 0}p{font-size: 108%}h2 {font-size: 120%}h3 {font-size: 80%}</style> <h2 class = 'thicker'>title</h2><h3>hehe    lala</h3>"];
    
    [allTitleStr replaceOccurrencesOfString:@"title" withString:_newsTitle options:NSCaseInsensitiveSearch range:[allTitleStr rangeOfString:@"title"]];
    [allTitleStr replaceOccurrencesOfString:@"hehe" withString:_source options:NSCaseInsensitiveSearch range:[allTitleStr rangeOfString:@"hehe"]];
    [allTitleStr replaceOccurrencesOfString:@"lala" withString:_time options:NSCaseInsensitiveSearch range:[allTitleStr rangeOfString:@"lala"]];
    
    NSMutableString *head = (NSMutableString *)@"<head><style>img{width:360px !important;}</style></head>";
    _contentHTMLString = [[[head stringByAppendingString:allTitleStr] stringByAppendingString:_homeText] stringByAppendingString:_bodyText];
    [_contentWebView loadHTMLString:_contentHTMLString baseURL:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_spinner stopAnimating];
        //[_spinner removeFromSuperview];
        //_spinner.hidden = YES;
    });
    
    }


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
