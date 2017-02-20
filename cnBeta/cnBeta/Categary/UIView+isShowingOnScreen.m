//
//  UIView+isShowingOnScreen.m
//  cnBeta
//
//  Created by hudy on 16/8/14.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "UIView+isShowingOnScreen.h"

@implementation UIView (isShowingOnScreen)
- (BOOL)isShowingOnKeyWindow
{
    //主窗口
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    //以窗口的左上角为坐标原点，计算self的矩形框
    CGRect newFrame = [keyWindow convertRect:self.frame fromView:self.superview];
    CGRect windowBounds = keyWindow.bounds;
    //判断newFrame是不是在windowBounds上
    BOOL isOnWindow = CGRectIntersectsRect(newFrame, windowBounds);
    
    return self.window == keyWindow && !self.hidden && self.alpha > 0.01 && isOnWindow;
}
@end
