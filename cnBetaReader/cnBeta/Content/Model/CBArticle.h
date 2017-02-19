//
//  CBArticle.h
//  cnBeta
//
//  Created by hudy on 2016/10/2.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CBArticleCacheStatus) {
    CBArticleCacheStatusNone,
    CBArticleCacheStatusCached,
    CBArticleCacheStatusFailed
};

@interface CBArticle : NSObject

@property (nonatomic, copy) NSString *newsId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *source;
@property (nonatomic, copy) NSString *summary;
@property (nonatomic, copy) NSString *pubTime;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *sn;
@property (nonatomic, copy) NSString *thumb;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSNumber *commentCount;
@property (nonatomic, copy) NSNumber *cacheStatus;
@property (nonatomic, readonly) NSArray *imageUrls;

- (BOOL)isStarred;
- (NSString *)toHTML;


@end
