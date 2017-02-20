//
//  CBCmtPostHeaderView.h
//  cnBeta
//
//  Created by hudy on 2017/1/15.
//  Copyright © 2017年 hudy. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CBHeaderViewDelegate <NSObject>

- (void)didTouchBackItem;

@end

@interface CBCmtPostHeaderView : UIView

@property (nonatomic, weak) id<CBHeaderViewDelegate> delegate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIColor *titleColor;

@end
