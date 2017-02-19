//
//  CBURLSessionWrapperOperation.h
//  cnBeta
//
//  Created by hudy on 2017/1/3.
//  Copyright © 2017年 hudy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CBURLRequestWrapperOperation : NSOperation

+ (instancetype)operationWithURLRequest:(NSURLRequest *)request;

- (void)createTaskWithCompletionBlock:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionBlock;

@end
