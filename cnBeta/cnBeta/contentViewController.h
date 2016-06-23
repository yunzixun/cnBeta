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
@property (nonatomic, strong) NSString *newsTitle;
@property (nonatomic, strong) NSString *bodyText;
@property (nonatomic, strong) NSString *homeText;
@property (nonatomic, strong) NSString *source;
@property (nonatomic, strong) NSString *time;

@property (nonatomic, strong) NSString *contentURL;

- (void)setupWebViewByData:(id)data;

@end
