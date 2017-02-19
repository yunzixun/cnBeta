//
//  CBCmtPostHeaderView.m
//  cnBeta
//
//  Created by hudy on 2017/1/15.
//  Copyright © 2017年 hudy. All rights reserved.
//

#import "CBCmtPostHeaderView.h"
#import "CBAppearanceManager.h"

@interface CBCmtPostHeaderView ()

@property (nonatomic, strong) UILabel *titleLbl;

@end

@implementation CBCmtPostHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, 56, 44)];
    [backBtn setImage:[UIImage imageNamed:@"toolbar_back_normal_50x50_"] forState:UIControlStateNormal];
    [backBtn addTarget:self.delegate action:@selector(didTouchBackItem) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:backBtn];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(120, 20, ScreenWidth-240, 40)];
    title.font = [UIFont systemFontOfSize:15];
    title.textAlignment = NSTextAlignmentCenter;
    self.titleLbl =title;
    [self addSubview:title];
    
    UIView *linev = [[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height-1, ScreenWidth, 1)];
    linev.backgroundColor = [UIColor colorWithRed:216/255.0f green:216/255.0f blue:216/255.0f alpha:1];
    [self addSubview:linev];
    
}

- (void)setTitle:(NSString *)title
{
    [self.titleLbl setText:title];
}

- (void)setTitleColor:(UIColor *)titleColor
{
    [self.titleLbl setTextColor:titleColor];
}


- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    self.backgroundColor = backgroundColor;
}


@end
