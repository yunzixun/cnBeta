//
//  CBSectionHeader.h
//  cnBeta
//
//  Created by hudy on 16/8/25.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CBSectionHeader : UIView

@property (nonatomic, weak) UITableView *tableview;
@property (nonatomic, assign)NSInteger section;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong)UIColor *headerColor;

@end
