//
//  NavTabBar.m
//  cnBeta
//
//  Created by hudy on 16/8/1.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "NavTabBar.h"
#import "Constant.h"

@interface NavTabBar ()
{
    UIScrollView *_navigationTabBar;
    UIView      *_underLine;
    NSArray     *_itemWidths;
}
@property (nonatomic, weak) UIButton *pressedButton;
@property (nonatomic, strong) NSMutableArray *itemButtons;

@end

@implementation NavTabBar

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initConfig];
        //[self setupWithItemArray];
        
    }
    return self;
}

- (void)initConfig
{
    _itemButtons = [@[] mutableCopy];
    
    _navigationTabBar = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 20, ScreenWidth, 44)];
    _navigationTabBar.backgroundColor = [UIColor clearColor];
    _navigationTabBar.showsHorizontalScrollIndicator = NO;
    [self addSubview:_navigationTabBar];
}

- (void)setupWithItems
{
    _itemWidths = [self getButtonsWidthWithTitles:_itemTitles];
    
    CGFloat contentWidth = [self contentWidthAndAddItemsWithButtonsWidth:_itemWidths];
    _navigationTabBar.contentSize = CGSizeMake(contentWidth, 0);
    
}

- (NSArray *)getButtonsWidthWithTitles:(NSArray *)titles
{
    NSMutableArray *widths = [NSMutableArray array];
    
    for (NSString * title in titles) {
        CGSize textSize = [title boundingRectWithSize:CGSizeMake(ScreenWidth, 44) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} context:nil].size;
        NSNumber *width = [NSNumber numberWithFloat:textSize.width];
        [widths addObject:width];
    }
    return widths;
}

- (CGFloat)contentWidthAndAddItemsWithButtonsWidth:(NSArray *)itemsWidth
{
    CGFloat lastWidth = 0;
    for (NSInteger index = 0; index < itemsWidth.count; index++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:_itemTitles[index] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        CGFloat buttonWidth = [itemsWidth[index] floatValue] + 15*2;
        button.frame = CGRectMake(lastWidth, 0, buttonWidth, 44);
        
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        [button addTarget:self action:@selector(pressItemButton:) forControlEvents:UIControlEventTouchUpInside];
        [_navigationTabBar addSubview:button];
        [_itemButtons addObject:button];
        lastWidth += buttonWidth;
    }
    self.pressedButton = [_itemButtons lastObject];
    [self showUnderLineWithButtonWidth:[itemsWidth[0] floatValue]];
    return lastWidth;
}

#pragma mark  设置下划线
- (void)showUnderLineWithButtonWidth:(CGFloat)buttonWidth
{
    _underLine = [[UIView alloc]initWithFrame:CGRectMake(15, 42, buttonWidth, 2)];
    _underLine.backgroundColor = [UIColor redColor];
    [_navigationTabBar addSubview:_underLine];
    
    //初始时按下第一个button
    UIButton *button = _itemButtons[0];
    button.selected = YES;
    [button setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
                         
}

- (void)pressItemButton:(UIButton *)button
{
        NSInteger index = [_itemButtons indexOfObject:button];
        [self.delegate didSelectItemAtIndex:index];
}

-(void)setCurrentItemIndex:(NSInteger)currentItemIndex
{
    _currentItemIndex = currentItemIndex;
    UIButton *button = _itemButtons[currentItemIndex];
    CGFloat flag = ScreenWidth;
    
    if (button.frame.origin.x + button.frame.size.width + 50 > flag) {
        CGFloat offsetD = button.frame.origin.x + button.frame.size.width - flag;
        if (currentItemIndex < _itemButtons.count - 1) {
            offsetD += button.frame.size.width;
        }
        [_navigationTabBar setContentOffset:CGPointMake(offsetD, 0) animated:YES];
    }else {
        [_navigationTabBar setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    
    if (self.pressedButton != button) {
        self.pressedButton.selected = NO;
        self.pressedButton = button;
        button.selected = YES;
        [button setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    }
    
    //下划线偏移
    [UIView animateWithDuration:0.1 animations:^{
        _underLine.frame = CGRectMake(button.frame.origin.x + 15, 42, [_itemWidths[currentItemIndex] floatValue], 2);
    }];

}

@end
