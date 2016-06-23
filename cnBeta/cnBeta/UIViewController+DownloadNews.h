//
//  UIViewController+DownloadNews.h
//  cnBeta
//
//  Created by hudy on 16/6/20.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CompletionBlock)(NSData *data, NSError *error);

@interface UIViewController (DownloadNews)

- (void)requestWithURL:(NSString *)url completion:(CompletionBlock)completionBlock;

@end
