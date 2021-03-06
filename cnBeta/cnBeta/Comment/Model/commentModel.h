//
//  commentModel.h
//  cnBeta
//
//  Created by hudy on 16/7/6.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface commentModel : NSObject

@property (nonatomic, copy)NSString *comment;
@property (nonatomic, copy)NSString *date;
@property (nonatomic, copy)NSString *icon;
@property (nonatomic, copy)NSString *name;
@property (nonatomic, copy)NSString *host_name;
@property (nonatomic, copy)NSString *sid;
@property (nonatomic, copy)NSString *pid;//被回复的id
@property (nonatomic, copy)NSString *tid;//评论id
@property (nonatomic, copy)NSString *reason;
@property (nonatomic, copy)NSString *score;
@property (nonatomic, copy)NSString *floor;
@property (nonatomic)BOOL supported;
@property (nonatomic)BOOL opposed;

- (CGSize)sizeWithConstrainedSize:(CGSize)size;

@end
