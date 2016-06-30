//
//  HTMLCache.h
//  cnBeta
//
//  Created by hudy on 16/6/29.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTMLCache : NSObject
{
@private
    NSFileManager *fileManager;
    NSString *cacheDirectory;
    dispatch_queue_t ioQueue;
}

+ (HTMLCache *)sharedCache;


//文件缓存
- (void)cacheHTMLToFile:(NSString *)HTMLString forKey:(NSString *)key;
- (NSString *)getHTMLFromFileForKey:(NSString *)key;
- (float)fileSizeAtPath:(NSString *)path;
- (float)folderSizeOfCache;
- (void)clearCache;

@end
