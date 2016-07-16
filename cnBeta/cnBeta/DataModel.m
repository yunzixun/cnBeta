//
//  DataModel.m
//  cnBeta
//
//  Created by hudy on 16/7/3.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "DataModel.h"

@implementation DataModel

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.pubtime forKey:@"pubtime"];
    [aCoder encodeObject:self.sid forKey:@"sid"];
    [aCoder encodeObject:self.counter forKey:@"counnter"];
    [aCoder encodeObject:self.comments forKey:@"comments"];
    [aCoder encodeObject:self.thumb forKey:@"thumb"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self.title = [aDecoder decodeObjectForKey:@"title"];
    self.pubtime = [aDecoder decodeObjectForKey:@"pubtime"];
    self.sid = [aDecoder decodeObjectForKey:@"sid"];
    self.counter = [aDecoder decodeObjectForKey:@"counter"];
    self.comments = [aDecoder decodeObjectForKey:@"comments"];
    self.thumb = [aDecoder decodeObjectForKey:@"thumb"];
    return self;
    
}

@end
