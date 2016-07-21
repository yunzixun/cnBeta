//
//  HTTPRequester.h
//  cnBeta
//
//  Created by hudy on 16/7/19.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CompletionBlock)(id responseObject, NSError *error);

@interface HTTPRequester : NSObject

+ (HTTPRequester *)sharedHTTPRequester;

- (void)fetchSecurityCodeForSid:(NSString *)sid completion:(CompletionBlock)block;

- (void)postCommentToNewsWithSid:(NSString *)sid content:(NSString *)content securityCode:(NSString *)code completion:(CompletionBlock)block;
- (void)replyCommentWithSid:(NSString *)sid andTid:(NSString *)tid content:(NSString *)content securityCode:(NSString *)code completion:(CompletionBlock)block;
- (void)voteCommentWithSid:(NSString *)sid andTid:(NSString *)tid actionType:(NSString *)action completion:(CompletionBlock)block;

@end
