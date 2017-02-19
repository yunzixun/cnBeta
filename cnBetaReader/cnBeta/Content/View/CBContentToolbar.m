//
//  CBContentToolbar.m
//  cnBeta
//
//  Created by hudy on 2017/1/15.
//  Copyright © 2017年 hudy. All rights reserved.
//

#import "CBContentToolbar.h"

@interface CBContentToolbar ()



@end

@implementation CBContentToolbar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
