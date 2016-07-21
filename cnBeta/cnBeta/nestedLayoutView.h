//
//  nestedLayoutView.h
//  cnBeta
//
//  Created by hudy on 16/7/16.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "commentModel.h"

@interface nestedLayoutView : UIView
- (instancetype)initWithFrame:(CGRect)frame andModel:(commentModel *)commentItem upperView:(UIView *)upperView isLast:(BOOL)isLast;
@end
