//
//  contentViewController.h
//  cnBeta
//
//  Created by hudy on 16/6/21.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface contentViewController : UIViewController

//@property (weak, nonatomic) UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIWebView *contentWebView;

@property (nonatomic, copy) NSString *newsId;
@property (nonatomic, copy) NSString *comments;
//@property (nonatomic, copy) NSString *thumb;
@property (nonatomic, copy) NSString *newsTitle;
@end
