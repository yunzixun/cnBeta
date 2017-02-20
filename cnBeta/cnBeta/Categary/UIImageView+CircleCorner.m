//
//  UIImageView+CircleCorner.m
//  cnBeta
//
//  Created by hudy on 16/8/24.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "UIImageView+CircleCorner.h"

@implementation UIImageView (CircleCorner)

- (UIImageView *)imageWithRoundedCornersSize:(float)cornerRadius
{
    UIImageView *imageView = self;
    UIImage * original = self.image;
    // Begin a new image that will be the new image with the rounded corners
    // (here with the size of an UIImageView)
    UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, NO, [UIScreen mainScreen].scale); //[UIScreen mainScreen].scale
    
    // Add a clip before drawing anything, in the shape of an rounded rect
    [[UIBezierPath bezierPathWithRoundedRect:imageView.bounds
                                cornerRadius:cornerRadius] addClip];
    // Draw your image
    [original drawInRect:imageView.bounds];
    
    // Get the image, here setting the UIImageView image
    imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    
    // Lets forget about that we were drawing
    UIGraphicsEndImageContext();
    
    return imageView;
}

@end
