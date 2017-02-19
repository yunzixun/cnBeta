//
//  CBURLSessionWrapperOperation.m
//  cnBeta
//
//  Created by hudy on 2017/1/3.
//  Copyright © 2017年 hudy. All rights reserved.
//

#import "CBURLRequestWrapperOperation.h"

@interface CBURLRequestWrapperOperation ()
{
    BOOL executing;  // 系统的 finished 是只读的，不能修改，所以只能重写一个。
    BOOL finished;
}

@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSURLSessionTask *task;

@property (nonatomic, assign) BOOL isObserving;

@end

@implementation CBURLRequestWrapperOperation

+ (instancetype)operationWithURLRequest:(NSURLRequest *)request;
{
    CBURLRequestWrapperOperation *operation = [[CBURLRequestWrapperOperation alloc] init];
    operation.request = request;
    return operation;
}

- (void)createTaskWithCompletionBlock:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionBlock
{
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:self.request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!completionBlock) {
            return;
        }
        completionBlock(response, data, error);
    }];
    self.task = task;
}

- (void)cancel
{
    [super cancel];
    [self.task cancel];
}

- (void)dealloc {
    [self stopObservingTask];
}

- (void)startObservingTask {
    @synchronized (self) {
        if (_isObserving) {
            return;
        }
        
        [_task addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
        _isObserving = YES;
    }
}

- (void)stopObservingTask { // 因为要在 dealloc 调，所以用下划线不用点语法
    @synchronized (self) {
        if (!_isObserving) {
            return;
        }
        
        _isObserving = NO;
        [_task removeObserver:self forKeyPath:@"state"];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (self.task.state == NSURLSessionTaskStateCanceling || self.task.state == NSURLSessionTaskStateCompleted) {
        [self stopObservingTask];
        [self completeOperation];
    }
}

#pragma mark - NSOperation methods

- (void)start {
    // Always check for cancellation before launching the task.
    if ([self isCancelled])
    {
        // Must move the operation to the finished state if it is canceled.
        [self willChangeValueForKey:@"isFinished"];
        finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    
    // If the operation is not canceled, begin executing the task.
    [self willChangeValueForKey:@"isExecuting"];
    [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)main {
    @try {
        [self startObservingTask];
        [self.task resume];
    }
    @catch (NSException * e) {
        NSLog(@"Exception %@", e);
    }
}

- (void)completeOperation {
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    
    executing = NO;
    finished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

- (BOOL)isAsynchronous {
    return YES;
}

- (BOOL)isExecuting {
    return executing;
}

- (BOOL)isFinished {
    return finished;
}


@end
