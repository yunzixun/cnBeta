//
//  fileCache.m
//  cnBeta
//
//  Created by hudy on 16/7/9.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "fileCache.h"

@implementation FileCache
+ (
   FileCache *)sharedCache
{
    static FileCache *fileCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fileCache = [[FileCache alloc]init];
    });
    return fileCache;
}

- (id)init
{
    if (self = [super init]) {
        ioQueue = dispatch_queue_create("greatCache", DISPATCH_QUEUE_SERIAL);
        fileManager = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        libDirectory = [paths objectAtIndex:0];
        cacheDirectory = NSTemporaryDirectory();
    }
    return self;
}

- (void)cacheNewsListToFile:(NSArray *)newsList forKey:(NSString *)key
{
    if (newsList) {
        dispatch_async(ioQueue, ^{
            NSString *fileName = key;
            NSString *filePath = [libDirectory stringByAppendingPathComponent:fileName];
            
            NSError *error;
            BOOL s = [NSKeyedArchiver archiveRootObject:newsList toFile:filePath];
            if (!s) {
                NSLog(@"%@",error);
            }
        });
    }
}

- (NSMutableArray *)getNewsListFromFileForKey:(NSString *)key
{
    if (!key) {
        return nil;
    }
    NSString *fileName = key;
    NSString *filePath = [libDirectory stringByAppendingPathComponent:fileName];
    if ([fileManager fileExistsAtPath:filePath]) {
        return [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    }
    return nil;
}

- (void)cacheObjectArrayToFile:(NSArray *)objects forKey:(NSString *)key
{
    if (objects) {
        dispatch_async(ioQueue, ^{
            NSString *fileName = key;
            NSString *filePath = [libDirectory stringByAppendingPathComponent:fileName];
            [objects writeToFile:filePath atomically:YES];
        });
    }
}


- (NSMutableArray*)getArrayFromFileForKey:(NSString *)key
{
    if (!key) {
        return nil;
    }
    NSString *fileName = key;
    NSString *filePath = [cacheDirectory stringByAppendingPathComponent:fileName];
    if ([fileManager fileExistsAtPath:filePath]) {
        return [NSMutableArray arrayWithContentsOfFile:filePath];
    }
    return nil;
}

- (void)cacheHTMLToFile:(NSString *)HTMLString forKey:(NSString *)key
{
    if (!HTMLString || !key) {
        return;
    }
    dispatch_async(ioQueue, ^{
        NSString *fileName = key;
        NSString *filePath = [cacheDirectory stringByAppendingPathComponent:fileName];
        BOOL s;
        NSError *error;
        s = [HTMLString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if (!s) {
            NSLog(@"%@",error);
        }
    });
}

- (NSString *)getHTMLFromFileForKey:(NSString *)key
{
    if (!key) {
        return nil;
    }
    NSString *fileName = key;
    NSString *filePath = [cacheDirectory stringByAppendingPathComponent:fileName];
    if ([fileManager fileExistsAtPath:filePath]) {
        return [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    }
    return nil;
}



- (float)fileSizeAtPath:(NSString *)path
{
    //NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        long long size = [fileManager attributesOfItemAtPath:path error:nil].fileSize;
        return size/1024.0/1024.0;
    }
    return 0;
}

- (float)folderSizeOfCache
{
    float folderSize = 0;
    if ([fileManager fileExistsAtPath:cacheDirectory]) {
        NSArray *childenFiles = [fileManager subpathsAtPath:cacheDirectory];
        for (NSString *fileName in childenFiles) {
            NSString *absolutePath = [cacheDirectory stringByAppendingPathComponent:fileName];
            folderSize += [self fileSizeAtPath:absolutePath];
        }
    }
    return folderSize;
}
- (void)clearCache
{
    if ([fileManager fileExistsAtPath:cacheDirectory]) {
        dispatch_async(ioQueue, ^{
            NSArray *childenFiles = [fileManager subpathsAtPath:cacheDirectory];
            for (NSString *fileName in childenFiles) {
                NSString *absolutePath = [cacheDirectory stringByAppendingPathComponent:fileName];
                [fileManager removeItemAtPath:absolutePath error:nil];
            }
        });
    }
}

@end
