//
//  contentViewController.m
//  cnBeta
//
//  Created by hudy on 16/6/22.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "contentViewController.h"
#import "UIViewController+DownloadNews.h"

@interface contentViewController ()
@end

@implementation contentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //[self.spinner setHidesWhenStopped:YES];
    [_spinner startAnimating];

    // Do any additional setup after loading the view.
}

- (void)setContentURL:(NSString *)contentURL
{
    _contentURL = contentURL;
    [self startDownloadContent];
}

- (void)startDownloadContent
{
    if (self.contentURL) {
        
        [self requestWithURL:self.contentURL completion:^(NSData *data, NSError *error) {
            if (!error) {
                NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil][@"result"];
                
                [self setupWebViewByData:dataDic];
            }
            //NSLog(@"%@",dic);
        }];
        
    }
}

- (void)setupWebViewByData:(id)data
{
    
    NSDictionary *dataDic = (NSDictionary *)data;
    self.newsTitle = dataDic[@"title"];
    self.homeText = dataDic[@"hometext"];
    self.bodyText = dataDic[@"bodytext"];
    self.source = dataDic[@"source"];
    self.time = dataDic[@"time"];
    
    NSMutableString *allTitleStr =[NSMutableString stringWithString:@"<style type='text/css'> p.thicker{font-weight: 500}p.light{font-weight: 0}p{font-size: 108%}h2 {font-size: 120%}h3 {font-size: 80%}</style> <h2 class = 'thicker'>xukun</h2><h3>hehe    lala</h3>"];
    
    [allTitleStr replaceOccurrencesOfString:@"xukun" withString:_newsTitle options:NSCaseInsensitiveSearch range:[allTitleStr rangeOfString:@"xukun"]];
    [allTitleStr replaceOccurrencesOfString:@"hehe" withString:_source options:NSCaseInsensitiveSearch range:[allTitleStr rangeOfString:@"hehe"]];
    [allTitleStr replaceOccurrencesOfString:@"lala" withString:_time options:NSCaseInsensitiveSearch range:[allTitleStr rangeOfString:@"lala"]];
    
    NSMutableString *head = (NSMutableString *)@"<head><style>img{width:360px !important;}</style></head>";
    NSString *allStr = [[[head stringByAppendingString:allTitleStr] stringByAppendingString:_homeText] stringByAppendingString:_bodyText];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_spinner stopAnimating];
        //[_spinner removeFromSuperview];
        //_spinner.hidden = YES;
    });
    
    //_spinner.hidden = YES;

    [_contentWebView loadHTMLString:allStr baseURL:nil];
    
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
