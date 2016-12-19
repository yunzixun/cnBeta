//
//  fileCache.m
//  cnBeta
//
//  Created by hudy on 16/7/9.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "fileCache.h"

@implementation FileCache
+ (FileCache *)sharedCache
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
        cachesDirectory = [paths objectAtIndex:0];  //cache目录
        tmpDirectory = NSTemporaryDirectory(); //tmp目录
    }
    return self;
}

- (void)cacheNewsListToFile:(NSArray *)newsList forKey:(NSString *)key
{
    if (newsList) {
        dispatch_async(ioQueue, ^{
            NSString *fileName = key;
            NSString *filePath = [cachesDirectory stringByAppendingPathComponent:fileName];
            
            [NSKeyedArchiver archiveRootObject:newsList toFile:filePath];
//            if (!s) {
//                NSLog(@"%@",error);
//            }
        });
    }
}

- (NSMutableArray *)getNewsListFromFileForKey:(NSString *)key
{
    if (!key) {
        return nil;
    }
    NSString *fileName = key;
    NSString *filePath = [cachesDirectory stringByAppendingPathComponent:fileName];
    if ([fileManager fileExistsAtPath:filePath]) {
        return [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    }
    return nil;
}




- (float)fileSizeAtPath:(NSString *)path
{
    //NSFileManager *fileManager = [NSFileManager defaultManager];
    
    long long size = [fileManager attributesOfItemAtPath:path error:nil].fileSize;
    return size/1024.0/1024.0;

}

- (float)folderSizeOfCache
{
    float folderSize = 0;
    if ([fileManager fileExistsAtPath:tmpDirectory]) {
        NSArray *childenFiles = [fileManager subpathsAtPath:tmpDirectory];
        for (NSString *fileName in childenFiles) {
            NSString *absolutePath = [tmpDirectory stringByAppendingPathComponent:fileName];
            folderSize += [self fileSizeAtPath:absolutePath];
        }
    }
    
    return folderSize;
}
- (void)clearCache
{
    if ([fileManager fileExistsAtPath:tmpDirectory]) {
        dispatch_async(ioQueue, ^{
            NSArray *childenFiles = [fileManager subpathsAtPath:tmpDirectory];
            for (NSString *fileName in childenFiles) {
                NSString *absolutePath = [tmpDirectory stringByAppendingPathComponent:fileName];
                [fileManager removeItemAtPath:absolutePath error:nil];
            }
        });
    }
    
    if ([fileManager fileExistsAtPath:cachesDirectory]) {
        dispatch_async(ioQueue, ^{
            NSArray *childenFiles = [fileManager subpathsAtPath:cachesDirectory];
            for (NSString *fileName in childenFiles) {
                NSString *absolutePath = [cachesDirectory stringByAppendingPathComponent:fileName];
                [fileManager removeItemAtPath:absolutePath error:nil];
            }
        });
    }
}

@end
