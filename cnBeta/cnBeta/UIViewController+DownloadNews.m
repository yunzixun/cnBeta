//
//  UIViewController+DownloadNews.m
//  cnBeta
//
//  Created by hudy on 16/6/20.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "UIViewController+DownloadNews.h"
#import "AFNetworking.h"
#import "NSString+MD5.h"


static NSString *const contentBaseURLString = @"http://api.cnbeta.com/capi?app_key=10000&format=json&method=Article.NewsContent&sid=";

@implementation UIViewController (DownloadNews)

- (void)requestWithURL:(NSString *)url completion:(CompletionBlock)completionBlock
{
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        completionBlock(data, error);
    }];
    [task resume];
    
}

- (void)requestWithURLType:(NSString *)type completion:(CompletionBlock)completionBlock
{
    [self requestWithURLType:type andId:nil completion:(CompletionBlock)completionBlock];
}

- (void)requestWithURLType:(NSString *)type andId:(NSString *)sid completion:(CompletionBlock)completionBlock
{
    NSString *url = nil;
    UInt64 timestamp = (UInt64)[[NSDate date]timeIntervalSince1970];
    //下拉刷新列表
    if ([type isEqualToString:@"updatedNews"]) {
        //md5加密
        NSString *md5String = [NSString stringWithFormat:@"app_key=10000&format=json&method=Article.Lists&timestamp=%llu&v=1.0&mpuffgvbvbttn3Rc", timestamp ];
        NSString *sign = [md5String MD5];
        
        url = [NSString stringWithFormat:@"http://api.cnbeta.com/capi?app_key=10000&format=json&method=Article.Lists&timestamp=%llu&v=1.0&sign=%@", timestamp, sign];
    //下拉加载更多
    } else if ([type isEqualToString:@"moreNews"]) {
        //md5加密
        NSString *md5String = [NSString stringWithFormat:@"app_key=10000&end_sid=%@&format=json&method=Article.Lists&timestamp=%llu&topicid=null&v=1.0&mpuffgvbvbttn3Rc", sid, timestamp ];
        NSString *sign = [md5String MD5];
        
        url = [NSString stringWithFormat:@"http://api.cnbeta.com/capi?app_key=10000&end_sid=%@&format=json&method=Article.Lists&timestamp=%llu&topicid=null&v=1.0&mpuffgvbvbttn3Rc&sign=%@", sid, timestamp, sign];
    //新闻详情
    }else if ([type isEqualToString:@"content"]){
        //md5加密
        NSString *md5String = [NSString stringWithFormat:@"app_key=10000&format=json&method=Article.NewsContent&sid=%@&timestamp=%llu&v=1.0&mpuffgvbvbttn3Rc", sid, timestamp ];
        NSString *sign = [md5String MD5];
        
        url = [NSString stringWithFormat:@"http://api.cnbeta.com/capi?app_key=10000&format=json&method=Article.NewsContent&sid=%@&timestamp=%llu&v=1.0&mpuffgvbvbttn3Rc&sign=%@", sid, timestamp, sign];
        
    //SN
    }else{
        url = [NSString stringWithFormat:@"http://www.cnbeta.com/articles/%@.htm",sid];
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    if ([type isEqualToString:@"SN"]) {
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    [manager GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completionBlock(responseObject, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completionBlock(nil, error);
    }];

        
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
//    NSURLSession *session = [NSURLSession sharedSession];
//    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        completionBlock(data, error);
//    }];
//    [task resume];
    
}

- (void)requestWithURL:(NSString *)url andHeaders:(NSDictionary *)headers completion:(CompletionBlock)completionBlock
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setTimeoutInterval:10.0];
    NSArray *allKey = [headers allKeys];
    for (NSString *key in allKey) {
        [manager.requestSerializer setValue:headers[key] forHTTPHeaderField:key];
    }
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    [manager.requestSerializer setTimeoutInterval:10.0];
//    NSArray *allKey = [headers allKeys];
//    for (NSString *key in allKey) {
//        [manager.requestSerializer setValue:headers[key] forHTTPHeaderField:key];
//    }
    [manager GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completionBlock(responseObject, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completionBlock(nil, error);
    }];
}

@end
