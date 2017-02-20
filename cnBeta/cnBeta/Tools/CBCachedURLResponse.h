//
//  CBCachedURLResponse.h
//  cnBeta
//
//  Created by hudy on 2016/12/16.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CBCachedURLResponse : NSObject <NSCoding>

@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, strong) NSData *responseData;

@end
