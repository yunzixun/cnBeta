//
//  CBCustomURLProtocol.m
//  cnBeta
//
//  Created by hudy on 2016/12/17.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "CBCustomURLProtocol.h"
#import "CBCachedURLResponse.h"
#import "CBObjectCache.h"

static NSString *const CBCustomURLProtocolHandledKey = @"CBCustomURLProtocolHandledKey";

@interface CBCustomURLProtocol () <NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSessionDataTask *task;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSURLResponse *response;


@end

@implementation CBCustomURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    if (![request.URL.scheme isEqualToString:@"cnbeta"]) {
        return NO;
    }
    
    if ([NSURLProtocol propertyForKey:CBCustomURLProtocolHandledKey inRequest:request]) {
        return NO;
    }
    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

- (void)startLoading
{
    NSString *cacheKey = self.request.URL.query;
    CBCachedURLResponse *cachedResponse = [[CBObjectCache sharedCache] objectForKey:cacheKey];
    if (cachedResponse && cachedResponse.response && cachedResponse.responseData) {
        NSURLResponse *response = cachedResponse.response;
        NSData *data = cachedResponse.responseData;
        
        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        [self.client URLProtocol:self didLoadData:data];
        [self.client URLProtocolDidFinishLoading:self];
        return;
    }
    
    if ([self.request.URL.absoluteString containsString:@"article.body.img"]) {
        UIImage *placeHolderImage = [UIImage imageNamed:@"iphone_webview_defaultimage"];
        NSData *data = UIImagePNGRepresentation(placeHolderImage);
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:[NSURL URLWithString:cacheKey] MIMEType:@"image/png" expectedContentLength:data.length textEncodingName:@"utf-8"];
        
        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        [self.client URLProtocol:self didLoadData:data];
        [self.client URLProtocolDidFinishLoading:self];
        return;
    }
    
    NSMutableURLRequest *newRequest = [self.request mutableCopy];
    [newRequest setTimeoutInterval:15];
    [NSURLProtocol setProperty:@YES forKey:CBCustomURLProtocolHandledKey inRequest:newRequest];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    self.task = [session dataTaskWithRequest:newRequest];
    [self.task resume];
    
}

- (void)stopLoading
{
    [self.task cancel];
}

#pragma mark * NSURLSession delegate callbacks

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    
    //cache image only
    NSString *MIMEType = [response.MIMEType lowercaseString];
    if (![MIMEType hasPrefix:@"image"]) {
        return;
    }
    
    self.responseData = [[NSMutableData alloc] init];
    self.response = response;
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    [[self client] URLProtocol:self didLoadData:data];
    [self.responseData appendData:data];
}

//- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask willCacheResponse:(NSCachedURLResponse *)proposedResponse completionHandler:(void (^)(NSCachedURLResponse * _Nullable))completionHandler
//{
//    if (!proposedResponse || [proposedResponse.data length] == 0) {
//        return;
//    }
//
//    CBCachedURLResponse *cachedResponse = [[CBCachedURLResponse alloc] init];
//    cachedResponse.response = proposedResponse.response;
//    cachedResponse.responseData = proposedResponse.data;
//    [[CBObjectCache sharedCache] storeObject:cachedResponse forKey:[self.request URL].absoluteString];
//    completionHandler(proposedResponse);
//}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error == nil) {
        [[self client] URLProtocolDidFinishLoading:self];
        
        if (!self.response || [self.responseData length] == 0) {
            return;
        }
        
        CBCachedURLResponse *cachedResponse = [[CBCachedURLResponse alloc] init];
        cachedResponse.response = self.response;
        cachedResponse.responseData = self.responseData;
        [[CBObjectCache sharedCache] storeObject:cachedResponse forKey:[self.request URL].absoluteString];
        
        
    } else {
        [[self client] URLProtocol:self didFailWithError:error];
    }
}


@end
