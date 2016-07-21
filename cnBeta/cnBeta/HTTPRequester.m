//
//  HTTPRequester.m
//  cnBeta
//
//  Created by hudy on 16/7/19.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "HTTPRequester.h"
#import "AFNetWorking.h"

@implementation HTTPRequester

+ (HTTPRequester *)sharedHTTPRequester
{
    static HTTPRequester *requester = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        requester = [[HTTPRequester alloc]init];
    });
    return requester;
}

- (NSString *)cookieCSRF_TOKEN
{
    NSHTTPCookieStorage *cs = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [cs cookies]) {
        if ([[cookie name] isEqualToString:@"csrf_token"]) {
            return [cookie value];
        }
    }
    return nil;
}


- (void)fetchSecurityCodeForSid:(NSString *)sid completion:(CompletionBlock)block
{
    NSString *urlString = [NSString stringWithFormat:@"http://www.cnbeta.com/captcha?refresh=1"];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
    NSString *referer = [NSString stringWithFormat:@"http://cnbeta.com/articles/%@.htm", sid];
    [manager.requestSerializer setValue:referer forHTTPHeaderField:@"Referer"];
    
    
    [manager GET:urlString parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dic = responseObject;
        NSString *url = dic[@"url"];
        if ([url length] != 0) {
            [self fetchSecurityCodeImageWithURLString:[NSString stringWithFormat:@"http://www.cnbeta.com%@", url] sid:sid completion:block];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        block(nil, error);
    }];
}

- (void)fetchSecurityCodeImageWithURLString:(NSString *)urlstring sid:(NSString *)sid completion:(CompletionBlock)block
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
    NSString *referer = [NSString stringWithFormat:@"http://cnbeta.com/articles/%@.htm", sid];
    [manager.requestSerializer setValue:referer forHTTPHeaderField:@"Referer"];
    
    [manager GET:urlstring parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        block(responseObject, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        block(nil, error);
    }];
}

- (void)postCommentToNewsWithSid:(NSString *)sid content:(NSString *)content securityCode:(NSString *)code completion:(CompletionBlock)block
{
    NSString *urlString = [NSString stringWithFormat:@"http://www.cnbeta.com/comment"];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager.requestSerializer setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
    [manager.requestSerializer setValue:@"http://www.cnbeta.com/" forHTTPHeaderField:@"Referer"];
    
    NSString *token = [self cookieCSRF_TOKEN];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]init];
    [parameters setObject:@"publish" forKey:@"op"];
    [parameters setObject:sid forKey:@"sid"];
    [parameters setObject:@"0" forKey:@"tid"];
    [parameters setObject:content forKey:@"content"];
    [parameters setObject:token forKey:@"csrf_token"];
    [parameters setObject:code forKey:@"seccode"];
    
    [manager POST:urlString parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        block(responseObject, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        block(nil, error);
    }];
    
}

- (void)replyCommentWithSid:(NSString *)sid andTid:(NSString *)tid content:(NSString *)content securityCode:(NSString *)code completion:(CompletionBlock)block
{
    NSString *urlString = [NSString stringWithFormat:@"http://www.cnbeta.com/comment"];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager.requestSerializer setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
    [manager.requestSerializer setValue:@"http://www.cnbeta.com/" forHTTPHeaderField:@"Referer"];
    
    NSString *token = [self cookieCSRF_TOKEN];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]init];
    [parameters setObject:@"publish" forKey:@"op"];
    [parameters setObject:sid forKey:@"sid"];
    [parameters setObject:tid forKey:@"pid"];
    [parameters setObject:content forKey:@"content"];
    [parameters setObject:token forKey:@"csrf_token"];
    [parameters setObject:code forKey:@"seccode"];
    
    [manager POST:urlString parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        block(responseObject, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        block(nil, error);
    }];
}

- (void)voteCommentWithSid:(NSString *)sid andTid:(NSString *)tid actionType:(NSString *)action completion:(CompletionBlock)block
{
    NSString *urlString = [NSString stringWithFormat:@"http://www.cnbeta.com/comment"];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager.requestSerializer setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
    [manager.requestSerializer setValue:@"http://www.cnbeta.com/" forHTTPHeaderField:@"Referer"];
    
    NSString *token = [self cookieCSRF_TOKEN];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]init];
    [parameters setObject:action forKey:@"op"];
    [parameters setObject:sid forKey:@"sid"];
    [parameters setObject:tid forKey:@"tid"];
    [parameters setObject:token forKey:@"csrf_token"];
    
    [manager POST:urlString parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        block(responseObject, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        block(error, nil);
    }];
}



@end
