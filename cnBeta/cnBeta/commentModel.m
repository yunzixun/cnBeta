//
//  commentModel.m
//  cnBeta
//
//  Created by hudy on 16/7/6.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "commentModel.h"
#import "Constant.h"
#import "DYAppearanceManager.h"

@implementation commentModel

- (CGSize)sizeWithConstrainedSize:(CGSize)size
{
    NSDictionary *attribute = @{NSFontAttributeName: CommentFont};
    CGSize textSize = [self.comment boundingRectWithSize:CGSizeMake(size.width, 0) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:attribute context:nil].size;
    return textSize;
}

@end
