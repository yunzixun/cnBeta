//
//  FileCache.h
//  cnBeta
//
//  Created by hudy on 16/7/9.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface FileCache : NSObject
{
@private
    NSFileManager *fileManager;
    NSString *tmpDirectory;
    NSString *cachesDirectory;
    dispatch_queue_t ioQueue;
}

+ (FileCache *)sharedCache;


//文件缓存
- (void)cacheNewsListToFile:(NSArray *)newsList forKey:(NSString *)key;
- (NSMutableArray *)getNewsListFromFileForKey:(NSString *)key;

- (float)fileSizeAtPath:(NSString *)path;
- (float)folderSizeOfCache;
- (void)clearCache;
@end
