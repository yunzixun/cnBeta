//
//  CBObjectCache.m
//  cnBeta
//
//  Created by hudy on 2016/12/14.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "CBObjectCache.h"
#import "NSString+MD5.h"

static NSString *const CBDataCacheDirName = @"com.cnbeta.CBObjectCache";

static const NSInteger kDefaultMaxCacheAge = 7 * 24 * 60 * 60;
static const NSInteger kDefaultMaxCacheSize = 512 * 1024 * 1024;

@interface CBObjectCache ()

@property (nonatomic, strong) NSCache *memCache;
@property (nonatomic, strong) dispatch_queue_t ioQueue;

@end

@implementation CBObjectCache

+ (instancetype)sharedCache
{
    static CBObjectCache *sharedCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCache = [[CBObjectCache alloc]init];
    });
    return sharedCache;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _maxCacheAge = kDefaultMaxCacheAge;
        _maxCacheSize = kDefaultMaxCacheSize;
        
        _memCache = [[NSCache alloc]init];
        _memCache.name = CBDataCacheDirName;
        
        _ioQueue = dispatch_queue_create("com.cnbeta.CBObjectCache", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)storeObject:(id<NSCoding>)object forKey:(NSString *)key
{
    [self storeObject:object forKey:key toDisk:YES];
}

- (void)storeObject:(id<NSCoding>)object forKey:(NSString *)key toDisk:(BOOL)toDisk
{
    if (!object || !key) {
        return;
    }
    
    [self.memCache setObject:object forKey:key];
    
    if (!toDisk) {
        return;
    }
    
    dispatch_async(_ioQueue, ^{
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:object];
        NSFileManager *manager = [NSFileManager defaultManager];
        if (![manager fileExistsAtPath:[self cachePath]]) {
            [manager createDirectoryAtPath:[self cachePath] withIntermediateDirectories:YES attributes:nil error:NULL];
        }
        if (![manager createFileAtPath:[self cachePathForKey:key] contents:data attributes:nil]) {
            NSLog(@"Failed save to disk.");
        }
    });

}

- (id)objectForKey:(NSString *)key
{
    id object = [self objectFromMemoryCacheForKey:key];
    if (!object) {
        object = [self objectFromDiskCacheForKey:key];
    }
    return object;
}

- (id)objectFromDiskCacheForKey:(NSString *)key
{
    NSString *filePath = [self cachePathForKey:key];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    if (data) {
        id object = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        //save to memory cache
        if (object) {
            [self.memCache setObject:object forKey:key];
        }
        return object;
    }
    return nil;
}

- (id)objectFromMemoryCacheForKey:(NSString *)key
{
    return [self.memCache objectForKey:key];
}

#pragma mark - ClearUp

- (void)clearMemoryCache
{
    [self.memCache removeAllObjects];
}


- (void)clearDiskCache
{
    [self clearDiskCacheOnCompletion:nil];
}

- (void)clearDiskCacheOnCompletion:(void (^)())completion
{
    dispatch_async(_ioQueue, ^{
        [[NSFileManager defaultManager] removeItemAtPath:[self cachePath] error:nil];
        [[NSFileManager defaultManager] createDirectoryAtPath:[self cachePath] withIntermediateDirectories:YES attributes:nil error:NULL];
    });
    
    if (!completion) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        completion();
    });
}

- (unsigned long long)cacheSize
{
    unsigned long long size = 0;
    NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:[self cachePath]];
    for (NSString *fileName in fileEnumerator) {
        NSString *filePath = [[self cachePath] stringByAppendingPathComponent:fileName];
        NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:NULL];
        size += [attrs fileSize];
    }
    return size/1024.0/1024.0;
}

- (void)clearExpiredDiskCache
{
    dispatch_async(_ioQueue, ^{
        NSFileManager *manager = [NSFileManager defaultManager];
        NSURL *diskCacheURL = [NSURL fileURLWithPath:[self cachePath] isDirectory:YES];
        NSArray *URLResourceKeys = @[NSURLIsDirectoryKey, NSURLContentModificationDateKey, NSURLTotalFileAllocatedSizeKey, NSURLFileSizeKey];
        NSDirectoryEnumerator *dirEnumerator = [manager enumeratorAtURL:diskCacheURL includingPropertiesForKeys:URLResourceKeys options:NSDirectoryEnumerationSkipsHiddenFiles errorHandler:nil];
        
        NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-self.maxCacheAge];
        NSMutableDictionary *cacheFiles = [[NSMutableDictionary alloc] init];
        NSUInteger currentCacheSize = 0;
        
        // Enumerate all of the files in the cache directory.  This loop has two purposes:
        //
        //  1. Removing files that are older than the expiration date.
        //  2. Storing file attributes for the size-based cleanup pass.
        for (NSURL *fileURL in dirEnumerator) {
            NSDictionary *resourceValues = [fileURL resourceValuesForKeys:URLResourceKeys error:NULL];
//            if (resourceValues[NSURLIsDirectoryKey]) {
//                continue;
//            }
            
            // Remove files that are older than the expiration date;
            if ([[resourceValues[NSURLContentModificationDateKey] laterDate:expirationDate] isEqualToDate:expirationDate]) {
                [manager removeItemAtURL:fileURL error:NULL];
                continue;
            }
            
            // Store a reference to this file and account for its total size.
            NSNumber *totalAllocatedSize = resourceValues[NSURLTotalFileAllocatedSizeKey];
            currentCacheSize += [totalAllocatedSize unsignedIntegerValue];
            [cacheFiles setObject:resourceValues forKey:fileURL];
        }
        
        // If our remaining disk cache exceeds a configured maximum size, perform a second
        // size-based cleanup pass.  We delete the oldest files first.
        if (currentCacheSize > self.maxCacheSize) {
            const NSUInteger desiredCacheSize = self.maxCacheSize/2;
            
            // Sort the remaining cache files by their last modification time (oldest first).
            NSArray *sortedFiles = [cacheFiles keysSortedByValueWithOptions:NSSortConcurrent
                                                            usingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                                                                return [obj1[NSURLContentModificationDateKey] compare:obj2[NSURLContentModificationDateKey]];
                                                            }];
            for (NSURL *fileUrl in sortedFiles) {
                if ([manager removeItemAtURL:fileUrl error:NULL]) {
                    NSDictionary *resourceValues = cacheFiles[fileUrl];
                    NSNumber *totalAllocatedSize = resourceValues[NSURLTotalFileAllocatedSizeKey];
                    currentCacheSize -= [totalAllocatedSize unsignedIntegerValue];
                    
                    if (currentCacheSize < desiredCacheSize) {
                        break;
                    }
                }
            }
        }
    });
}

#pragma mark - Private

- (NSString *)cachePath
{
    static NSString *cachePath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cachePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:CBDataCacheDirName];
    });
    return cachePath;
}

- (NSString *)cachePathForKey:(NSString *)key
{
    NSString *md5FileName = [key MD5];
    NSString *path = [[self cachePath] stringByAppendingPathComponent:md5FileName];
    return path;
}


@end
