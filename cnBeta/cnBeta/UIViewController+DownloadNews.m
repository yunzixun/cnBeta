//
//  UIViewController+DownloadNews.m
//  cnBeta
//
//  Created by hudy on 16/6/20.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "UIViewController+DownloadNews.h"


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


@end
