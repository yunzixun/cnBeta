//
//  CBURLCache.m
//  cnBeta
//
//  Created by hudy on 2016/12/17.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "CBURLCache.h"
#import "CBCachedURLResponse.h"
#import "CBObjectCache.h"

@implementation CBURLCache

- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request
{
    NSString *cacheKey = [request URL].absoluteString;
    CBCachedURLResponse *cachedResponse = [[CBObjectCache sharedCache] objectForKey:cacheKey];
    if (cachedResponse && cachedResponse.response && cachedResponse.responseData) {
        return [[NSCachedURLResponse alloc] initWithResponse:cachedResponse.response data:cachedResponse.responseData];;
    }
    
    return [super cachedResponseForRequest:request];
}

@end
