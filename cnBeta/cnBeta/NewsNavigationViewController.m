//
//  NewsNavigationViewController.m
//  cnBeta
//
//  Created by hudy on 16/8/11.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "NewsNavigationViewController.h"

@interface NewsNavigationViewController ()<UIGestureRecognizerDelegate>

@end

@implementation NewsNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isOn = [defaults boolForKey:@"手势操作"];
    BOOL everLaunch = [defaults boolForKey:@"everLaunched"];
    if (!everLaunch) {
        isOn = YES;
    }
    if (isOn) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults boolForKey:@"homepageLoaded"]) {
            if (self.pan == nil) {
                id target = self.interactivePopGestureRecognizer.delegate;
                //NSLog(@"%@", target);
                // 创建全屏滑动手势，调用系统自带滑动手势的target的action方法
                //SEL handleTransition = NSSelectorFromString(@"handleNavigationTransition:");
                UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:target action:@selector(handleNavigationTransition:)];
                self.pan = pan;
                
                // 设置手势代理，拦截手势触发
                pan.delegate = self;
                
                // 给导航控制器的view添加全屏滑动手势
                [self.view addGestureRecognizer:pan];
            }
            self.pan.enabled = YES;
        } else {
            //NSLog(@"%@", self.interactivePopGestureRecognizer);
            // 获取系统自带滑动手势的target对象
            id target = self.interactivePopGestureRecognizer.delegate;
            //NSLog(@"%@", target);
            // 创建全屏滑动手势，调用系统自带滑动手势的target的action方法
            //SEL handleTransition = NSSelectorFromString(@"handleNavigationTransition:");
            UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:target action:@selector(handleNavigationTransition:)];
            self.pan = pan;
            
            // 设置手势代理，拦截手势触发
            pan.delegate = self;
            
            // 给导航控制器的view添加全屏滑动手势
            [self.view addGestureRecognizer:pan];
            
            [defaults setBool:YES forKey:@"homepageLoaded"];
        }
        
        
        // 禁止使用系统自带的滑动手势
        self.interactivePopGestureRecognizer.enabled = NO;
        
    } else {
        //[self.view removeGestureRecognizer:self.pan];
        self.pan.enabled = NO;
        self.interactivePopGestureRecognizer.enabled = YES;
//        if (!self.pan.enabled) {
//            NSLog(@"1");
//        }
        
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    // 注意：只有非根控制器才有滑动返回功能，根控制器没有。
    // 判断导航控制器是否只有一个子控制器，如果只有一个子控制器，肯定是根控制器
    if (self.childViewControllers.count == 1) {
        // 表示用户在根控制器界面，就不需要触发滑动手势，
        return NO;
    }
    return YES;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
