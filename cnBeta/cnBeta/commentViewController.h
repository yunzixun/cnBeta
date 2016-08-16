//
//  commentViewController.h
//  cnBeta
//
//  Created by hudy on 16/7/7.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface commentViewController : UIViewController

@property (nonatomic,assign)BOOL isExpired;

- (id)initWithSid:(NSString *)sid andSN:(NSString *)sn Type:(BOOL)isExpired;

@end
