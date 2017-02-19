//
//  CBCmtListHeaderView.m
//  cnBeta
//
//  Created by hudy on 2017/1/15.
//  Copyright © 2017年 hudy. All rights reserved.
//

#import "CBCmtListHeaderView.h"
#import "CBAppearanceManager.h"

@interface CBCmtListHeaderView ()

@property (nonatomic, strong) UILabel *titleLbl;
@property (nonatomic, strong) UIImageView *titleView;

@end

@implementation CBCmtListHeaderView

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
    UILabel * titleLbl = [[UILabel alloc] init];
    self.titleLbl = titleLbl;

    UIView *linev = [[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height-1, ScreenWidth, 1)];
    linev.backgroundColor = [UIColor colorWithRed:216/255.0f green:216/255.0f blue:216/255.0f alpha:1];
    [self addSubview:linev];
    
}

- (void)setupTitleView
{
    UIImageView *titleView = [[UIImageView alloc] init];
    self.titleView = titleView;
    self.titleLbl.font = cmtTitle;
    self.titleLbl.numberOfLines = 2;
    [self.titleLbl setTextColor:cmtHeaderColor];
    
    NSDictionary *attribute = @{NSFontAttributeName: cmtTitle};
    CGSize textSize = [self.titleLbl.text boundingRectWithSize:CGSizeMake(ScreenWidth - 100, 0) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:attribute context:nil].size;
    
    [self.titleLbl setFrame:CGRectMake(10, 0, ScreenWidth - 100, textSize.height<40 ? textSize.height:40)];
    titleView.frame = CGRectMake(40, 0, ScreenWidth - 80, textSize.height<40 ? textSize.height:40);
    
    [self addSubview:titleView];
    [titleView addSubview:self.titleLbl];
}

- (void)setTitle:(NSString *)title
{
    [self.titleLbl setText:title];
    [self setupTitleView];
}

- (void)setTitleColor:(UIColor *)titleColor
{
    [self.titleLbl setTextColor:titleColor];
}

- (void)setTitleBackGroundColor:(UIColor *)titleBackGroundColor
{
    self.titleView.backgroundColor = titleBackGroundColor;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    self.backgroundColor = backgroundColor;
}

@end
