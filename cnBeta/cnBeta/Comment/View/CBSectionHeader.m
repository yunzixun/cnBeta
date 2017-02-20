//
//  CBSectionHeader.m
//  cnBeta
//
//  Created by hudy on 16/8/25.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "CBSectionHeader.h"
#import "CBAppearanceManager.h"
#import "CBAppSettings.h"

@interface CBSectionHeader ()

@property (nonatomic, strong)UIView  *edgeView;
@property (nonatomic, strong)UILabel *label;

@end

@implementation CBSectionHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _edgeView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 3, frame.size.height)];
        [self addSubview:_edgeView];
        
        _label = [[UILabel alloc]initWithFrame:CGRectMake(3, 0, ScreenWidth - 3, frame.size.height)];
        _label.backgroundColor = [UIColor clearColor];
        _label.font = [[CBAppearanceManager sharedManager].CBFont fontWithSize:13];
        [self addSubview:_label];
    }
    return self;
}

- (NSString *)text
{
    return [self.label text];
}

- (void)setText:(NSString *)text
{
    [self.label setText:text];
}

- (UIColor *)headerColor
{
    return [self.label textColor];
}

- (void)setHeaderColor:(UIColor *)headerColor
{
    [self.edgeView setBackgroundColor:headerColor];
    [self.label setTextColor:headerColor];
}

- (void)setFrame:(CGRect)frame{
    //NSLog(@"_______ frame = %@",NSStringFromCGRect(frame));
    
    CGRect sectionRect = [self.tableview rectForSection:self.section];
    CGRect newFrame = CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(sectionRect), CGRectGetWidth(frame), CGRectGetHeight(frame));
    [super setFrame:newFrame];
}

@end
