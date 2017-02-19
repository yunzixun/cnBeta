//
//  CBHTTPURLProtocol.m
//  cnBeta
//
//  Created by hudy on 2016/12/13.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "CBHTTPURLProtocol.h"
#import "CBCachedURLResponse.h"
#import "CBObjectCache.h"

static NSString *const CBHTTPURLProtocolHandledKey = @"CBHTTPURLProtocolHandledKey";

@interface CBHTTPURLProtocol () <NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSessionTask *task;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic ,strong) NSURLResponse *response;


@end

@implementation CBHTTPURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
//    NSLog(@"%@", request.URL.absoluteString);
//    if ([request.URL.absoluteString containsString:@"iqiyi.com"]) {
//        NSLog(@"%@", request.URL.absoluteString);
//        return NO;
//    }
    if (![request.URL.scheme isEqualToString:@"http"] && ![request.URL.scheme isEqualToString:@"https"]) {
        return NO;
    }
    if ([NSURLProtocol propertyForKey:CBHTTPURLProtocolHandledKey inRequest:request]) {
        return NO;
    }
    if (![request.URL.absoluteString containsString:@"jpg"] && ![request.URL.absoluteString containsString:@"png"] && ![request.URL.absoluteString containsString:@"gif"] && ![request.URL.absoluteString containsString:@"jpeg"]) {
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
    NSString *cacheKey = self.request.URL.absoluteString;
    CBCachedURLResponse *cachedResponse = [[CBObjectCache sharedCache] objectForKey:cacheKey];
    if (cachedResponse && cachedResponse.responseData && cachedResponse.response) {
        NSURLResponse *response = cachedResponse.response;
        NSData *data = cachedResponse.responseData;
        
        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        [self.client URLProtocol:self didLoadData:data];
        [self.client URLProtocolDidFinishLoading:self];
        return;
    }
    
    NSMutableURLRequest *newRequest = [self.request mutableCopy];
    [newRequest setTimeoutInterval:20];
    [NSURLProtocol setProperty:@YES forKey:CBHTTPURLProtocolHandledKey inRequest:newRequest];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.requestCachePolicy = NSURLCacheStorageNotAllowed;
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
//    completionHandler(nil);
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

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler
{
    if (response) {
        // simply consider redirect as an error
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorResourceUnavailable userInfo:nil];
        [[self client] URLProtocol:self didFailWithError:error];
    }
    completionHandler(request);
}



//- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler
//{
//    [[self client] URLProtocol:self didReceiveAuthenticationChallenge:challenge];
//    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
//    completionHandler(disposition,nil);
//}

@end
