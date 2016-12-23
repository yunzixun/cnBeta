//
//  HTTPRequester.h
//  cnBeta
//
//  Created by hudy on 16/7/19.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CompletionBlock)(id responseObject, NSError *error);

@interface CBHTTPRequester : NSObject

@property (nonatomic, strong) NSURLSessionTask *requestTask;

+ (CBHTTPRequester *)requester;

- (void)fetchSecurityCodeForSid:(NSString *)sid completion:(CompletionBlock)block;

- (void)postCommentToNewsWithSid:(NSString *)sid content:(NSString *)content securityCode:(NSString *)code completion:(CompletionBlock)block;

- (void)replyCommentWithSid:(NSString *)sid andTid:(NSString *)tid content:(NSString *)content securityCode:(NSString *)code completion:(CompletionBlock)block;

- (void)voteCommentWithSid:(NSString *)sid andTid:(NSString *)tid actionType:(NSString *)action completion:(CompletionBlock)block;


- (void)requestWithURLType:(NSString *)type completion:(CompletionBlock)completionBlock;

- (void)requestWithURLType:(NSString *)type andId:(NSString *)sid completion:(CompletionBlock)completionBlock;

- (void)requestWithURL:(NSString *)url andHeaders:(NSDictionary *)headers completion:(CompletionBlock)completionBlock;

<<<<<<< HEAD
- (void)fetchNewsListWithURL:(NSString *)url andHeaders:(NSDictionary *)headers completion:(void (^)(NSError *))completionBlock;

- (void)fetchArticleWithSid:(NSString *)sid completion:(CompletionBlock)block;

=======
>>>>>>> parent of c5a4779... v1.3.3
- (void)cancel;

@end
