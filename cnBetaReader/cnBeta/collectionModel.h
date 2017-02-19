//
//  collectionModel.h
//  cnBeta
//
//  Created by hudy on 16/7/8.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface collectionModel : NSObject

/**
 *  新闻标题
 */
@property (nonatomic , copy) NSString * title;

/**
 *  新闻ID
 */
@property (nonatomic , copy) NSString * sid;

/**
 *  收藏的时间
 */
@property (nonatomic , copy) NSString * time;

/**
 *  缩略图
 */
@property (nonatomic , copy) NSString * thumb;

@end
