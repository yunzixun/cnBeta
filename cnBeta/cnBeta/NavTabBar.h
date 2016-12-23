//
//  NavTabBar.h
//  cnBeta
//
//  Created by hudy on 16/8/1.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol navTabBarDelegate <NSObject>

- (void)didSelectItemAtIndex:(NSInteger)index;

@end

@interface NavTabBar : UIView

@property (nonatomic, weak) id<navTabBarDelegate>delegate;
@property (nonatomic, strong) NSArray *itemTitles;
@property (nonatomic, assign) NSInteger currentItemIndex;


- (instancetype)initWithFrame:(CGRect)frame;

- (void)setupWithItems;

@end
