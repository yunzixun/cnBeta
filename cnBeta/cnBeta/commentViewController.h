//
//  commentViewController.h
//  cnBeta
//
//  Created by hudy on 16/7/7.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBArticle.h"

@interface commentViewController : UIViewController

@property (nonatomic,assign)BOOL isExpired;

- (id)initWithArticle:(CBArticle *)article Type:(BOOL)isExpired;

@end
