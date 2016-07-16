//
//  UIViewController+DownloadNews.h
//  cnBeta
//
//  Created by hudy on 16/6/20.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CompletionBlock)(id data, NSError *error);

@interface UIViewController (DownloadNews)

- (void)requestWithURL:(NSString *)url completion:(CompletionBlock)completionBlock;
- (void)requestWithURLType:(NSString *)type completion:(CompletionBlock)completionBlock;
- (void)requestWithURLType:(NSString *)type andId:(NSString *)sid completion:(CompletionBlock)completionBlock;
- (void)requestWithURL:(NSString *)url andHeaders:(NSDictionary *)headers completion:(CompletionBlock)completionBlock;

@end
