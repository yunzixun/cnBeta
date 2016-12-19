//
//  HTTPRequester.m
//  cnBeta
//
//  Created by hudy on 16/7/19.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "CBHTTPRequester.h"
#import "AFNetWorking.h"
#import "MJExtension.h"
#import "NSString+MD5.h"
#import "TFHpple.h"
#import "CBDataBase.h"
#import "CBArticle.h"
#import "CBArticleParser.h"

@implementation CBHTTPRequester

+ (CBHTTPRequester *)requester
{
    return [[[self class] alloc] init];
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
    
    
    self.requestTask = [manager GET:urlString parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dic = responseObject;
        NSString *url = dic[@"url"];
        if ([url length] != 0) {
            [self fetchSecurityCodeImageWithURLString:[NSString stringWithFormat:@"http://www.cnbeta.com%@", url] sid:sid completion:^(id responseObject, NSError *error) {
                if (!error) {
                    block(responseObject,nil);
                } else {
                    block(nil,error);
                }
            }];
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
    
    self.requestTask = [manager GET:urlstring parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
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
    
    self.requestTask = [manager POST:urlString parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
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
    
    self.requestTask = [manager POST:urlString parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
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
    
    self.requestTask = [manager POST:urlString parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        block(responseObject, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        block(nil, error);
    }];
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
        NSString *md5String = [NSString stringWithFormat:@"app_key=10003&format=json&method=Article.Lists&timestamp=%llu&v=1.0&mpuffgvbvbttn3Rc", timestamp ];
        NSString *sign = [md5String MD5];
        
        url = [NSString stringWithFormat:@"http://api.cnbeta.com/capi?app_key=10003&format=json&method=Article.Lists&timestamp=%llu&v=1.0&sign=%@", timestamp, sign];
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
        
    }else {
        //url = @"http://cnbeta.techoke.com/api/list?version=1.8.6&init=1";
        url = @"http://182.92.195.110/api/news?version=2.2.0&init=1";
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setTimeoutInterval:10.0];
    if ([type isEqualToString:@"SN"]) {
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    self.requestTask = [manager GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completionBlock(responseObject, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completionBlock(nil, error);
    }];
    
}

- (void)requestWithURL:(NSString *)url andHeaders:(NSDictionary *)headers completion:(CompletionBlock)completionBlock
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setTimeoutInterval:10.0];
    NSArray *allKey = [headers allKeys];
    for (NSString *key in allKey) {
        [manager.requestSerializer setValue:headers[key] forHTTPHeaderField:key];
    }
    
    self.requestTask = [manager GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completionBlock(responseObject, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completionBlock(nil, error);
    }];
}

- (void)fetchNewsListWithURL:(NSString *)url andHeaders:(NSDictionary *)headers completion:(void (^)(NSError *))completionBlock
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setTimeoutInterval:10.0];
    NSArray *allKey = [headers allKeys];
    for (NSString *key in allKey) {
        [manager.requestSerializer setValue:headers[key] forHTTPHeaderField:key];
    }
    
    self.requestTask = [manager GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *dataList = [NewsModel mj_objectArrayWithKeyValuesArray:responseObject[@"result"][@"list"]];
        for (NewsModel *news in dataList) {
            [[CBDataBase sharedDataBase] cacheNews:news];
        }

        completionBlock(nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completionBlock(error);
    }];
}


- (void)fetchArticleWithSid:(NSString *)sid completion:(CompletionBlock)block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CBArticle *article = [[CBDataBase sharedDataBase] articleWithSid:sid];
        if (article && article.newsId == sid) {
            block(article,nil);
            return;
        }
        article = [[CBArticle alloc] init];
        NSString *url = [NSString stringWithFormat:@"http://www.cnbeta.com/articles/%@.htm",sid];
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager.requestSerializer setTimeoutInterval:10.0];
        self.requestTask = [manager GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            TFHpple *hpple = [[TFHpple alloc] initWithHTMLData:responseObject];
            [CBArticleParser parseArticle:article hpple:hpple];
            article.newsId = sid;
            [[CBDataBase sharedDataBase] cacheArticle:article];
            block(article,nil);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            block(nil,error);
        }];
    });
                   

}

- (void)cancel
{
    [self.requestTask cancel];
}
@end
