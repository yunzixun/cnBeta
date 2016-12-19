//
//  CBCachedURLResponse.m
//  cnBeta
//
//  Created by hudy on 2016/12/16.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "CBCachedURLResponse.h"

@implementation CBCachedURLResponse

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _response = [aDecoder decodeObjectForKey:@"response"];
        _responseData = [aDecoder decodeObjectForKey:@"responseData"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_response forKey:@"response"];
    [aCoder encodeObject:_responseData forKey:@"responseData"];
}

@end
