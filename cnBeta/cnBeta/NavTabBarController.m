//
//  NavTabBarController.m
//  cnBeta
//
//  Created by hudy on 16/8/6.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "NavTabBarController.h"
#import "Constant.h"
#import "NavTabBar.h"
#import "NewsTableViewController.h"
#import "otherNewsViewController.h"

@interface NavTabBarController ()<UIScrollViewDelegate, navTabBarDelegate>
{
    NavTabBar     *_navTabBar;
    UIScrollView  *_mainView;
    
}
@property(nonatomic, strong) NSMutableArray *subViewControllers;
@property (nonatomic, assign) NSInteger currentItemIndex;

@end

@implementation NavTabBarController

- (NSMutableArray *)subViewControllers
{
    if (!_subViewControllers) {
        _subViewControllers = [[NSMutableArray alloc]init];
    }
    return _subViewControllers;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self initSubViewControllers];
    [self initConfig];
}

- (void)initSubViewControllers
{
    NSArray *typeArray = @[@"dig", @"soft", @"industry", @"interact"];//, @"jhcomment"];
    
    NewsTableViewController *newsTvc = [[NewsTableViewController alloc]init];
    [self.subViewControllers addObject:newsTvc];
    
    for (NSString *type in typeArray) {
        otherNewsViewController *othervc = [[otherNewsViewController alloc]init];
        othervc.type = type;
        [self.subViewControllers addObject:othervc];
    }
    
    
}

- (void)initConfig
{
    NSArray *itemArray = @[@"全部资讯", @"人气推荐", @"软件版", @"业界版", @"互动版"];
    _navTabBar = [[NavTabBar alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 64)];
    _navTabBar.itemTitles = itemArray;
    _navTabBar.delegate = self;
    [_navTabBar setupWithItems];
    [self.view addSubview:_navTabBar];
    
    _mainView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight - 64)];
    _mainView.contentSize = CGSizeMake(itemArray.count * ScreenWidth, 0);
    _mainView.delegate = self;
    _mainView.pagingEnabled = YES;
    _mainView.bounces = NO;
    _mainView.showsVerticalScrollIndicator = NO;
    _mainView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_mainView];
    
    //加载第一个子视图
    self.currentItemIndex = 0;
    UIViewController *viewController = _subViewControllers[0];
    viewController.view.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight - 64 - 49);
    [_mainView addSubview:viewController.view];
    [self addChildViewController:viewController];
    
    UIView *linev = [[UIView alloc]initWithFrame:CGRectMake(0, 64, ScreenWidth, 1)];
    linev.backgroundColor = [UIColor colorWithRed:216/255.0f green:216/255.0f blue:216/255.0f alpha:1];
    [self.view addSubview:linev];
    
    
}


#pragma mark - navTabBarDelegate

- (void)didSelectItemAtIndex:(NSInteger)index
{
    [_mainView setContentOffset:CGPointMake(index * ScreenWidth, 0) animated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    /**  scrollview滚动时加载对应的视图  */
    _currentItemIndex = _mainView.contentOffset.x / ScreenWidth;
    _navTabBar.currentItemIndex = _currentItemIndex;
    UIViewController *viewController = _subViewControllers[_currentItemIndex];
    viewController.view.frame = CGRectMake(_currentItemIndex * ScreenWidth, 0, ScreenWidth, ScreenHeight - 64 -49);
    [_mainView addSubview:viewController.view];
    [self addChildViewController:viewController];
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [_navTabBar refreshTitleFont];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    //[self.navigationController setNavigationBarHidden:NO];
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
