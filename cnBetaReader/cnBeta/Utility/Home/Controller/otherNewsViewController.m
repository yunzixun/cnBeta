//
//  otherNewsViewController.m
//  cnBeta
//
//  Created by hudy on 16/8/5.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "otherNewsViewController.h"
#import "Constant.h"
#import "MJExtension.h"
#import "MJRefresh.h"
#import "CBHTTPRequester.h"
#import "CBDataBase.h"
#import "UIView+isShowingOnScreen.h"
#import "WKProgressHUD.h"
#import "contentViewController.h"
#import "CBNewsListCell.h"
#import "CBPadNewsListCell.h"
#import "CBNewsListTableView.h"
#import "CBAppSettings.h"

static CGFloat kTabbarHeight = 49.0f;

@interface otherNewsViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, assign) NSUInteger RowCount;
@property (nonatomic, strong) CBNewsListTableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, assign) int page;

@property (nonatomic, weak) UIViewController *lastVC;

@end

@implementation otherNewsViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc]init];
    }
    return _dataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
//    backItem.title = @"返回";
//    self.navigationItem.backBarButtonItem = backItem;
    
    [self initTableView];
    [self setupRefreshView];
    
    //监听点击TabBar的通知
    self.lastVC = self.tabBarController.selectedViewController;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tabBarClick) name:@"TabRefresh" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:CBAppSettingThemeChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:CBAppSettingFontChangedNotification object:nil];

}

- (void)reload
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)initTableView
{
    CBNewsListTableView *tableView = [[CBNewsListTableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 64) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    UIEdgeInsets insets = [self.tableView contentInset];
    insets.bottom = kTabbarHeight;
    self.tableView.contentInset = insets;
    self.tableView.scrollIndicatorInsets = insets;
    self.tableView.rowHeight = isPad ? 120.0f : 80.0f;
    self.tableView.tableFooterView=[[UIView alloc]init];
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
        
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)])  {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tabBarClick
{
    if (self.tabBarController.selectedViewController == self.lastVC && [self.view isShowingOnKeyWindow]) {
        [self.tableView.mj_header beginRefreshing];
    }
    
    self.lastVC = self.tabBarController.selectedViewController;
}

- (void)setupRefreshView
{
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefresh)];
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
    [self.tableView.mj_header beginRefreshing];
    
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefresh)];
}


- (void)headerRefresh
{
    self.page = 1;
    NSString *url = [NSString stringWithFormat:@"http://www.cnbeta.com/more?type=%@&page=1", self.type];
    NSMutableDictionary *headers = [[NSMutableDictionary alloc]init];
    [headers setObject:@"http://www.cnbeta.com/" forKey:@"Referer"];
    [[CBHTTPRequester requester] requestWithURL:url andHeaders:headers completion:^(id data, NSError *error) {
        if (!error) {
            //NSLog(@"%@",data[@"result"]);
            NSArray *dataList = [NewsModel mj_objectArrayWithKeyValuesArray:data[@"result"][@"list"]];
            for (NewsModel *news in dataList) {
                [[CBDataBase sharedDataBase] cacheNews:news];
            }

            [self.dataSource removeAllObjects];
            for (NewsModel *news in dataList) {
                [self.dataSource addObject:[[CBDataBase sharedDataBase] newsWithSid:news.sid]];
            }
            self.RowCount = [self.dataSource count];
            [self.tableView reloadData];
        } else {
            [WKProgressHUD popMessage:error.userInfo[@"NSLocalizedDescription"] inView:self.view duration:1.5 animated:YES];
        }
        [self.tableView.mj_header endRefreshing];
    }];
}


- (void)footerRefresh
{
    NSString *url = [NSString stringWithFormat:@"http://www.cnbeta.com/more?type=%@&page=%d", self.type, self.page];
    NSMutableDictionary *headers = [[NSMutableDictionary alloc]init];
    [headers setObject:@"http://www.cnbeta.com/" forKey:@"Referer"];
    [[CBHTTPRequester requester] requestWithURL:url andHeaders:headers completion:^(id data, NSError *error) {
        if (!error) {
            NSArray *dataList = [NewsModel mj_objectArrayWithKeyValuesArray:data[@"result"][@"list"]];
            for (NewsModel *news in dataList) {
                [[CBDataBase sharedDataBase] cacheNews:news];
            }

            for (NewsModel *news in dataList) {
                [self.dataSource addObject:[[CBDataBase sharedDataBase] newsWithSid:news.sid]];
            }
            self.RowCount = [self.dataSource count];
            [self.tableView reloadData];
            [self.tableView.mj_footer endRefreshing];
            self.page ++;
        }else {
            [self.tableView.mj_footer endRefreshing];
        }
    }];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _RowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CBTableViewCell *cell = isPad ? [CBPadNewsListCell cellWithTableView:tableView] : [CBNewsListCell cellWithTableView:tableView];
    cell.newsModel = self.dataSource[indexPath.row];
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]){
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    return cell;
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewsModel *currentNews= _dataSource[indexPath.row];
    if (!currentNews.read) {
        [currentNews setRead:@YES];
        [[CBDataBase sharedDataBase] updateReadField:currentNews];
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    contentViewController *contentvc = [mainStoryboard instantiateViewControllerWithIdentifier:@"contentViewController"];
    contentvc.newsId = currentNews.sid;
    contentvc.thumb = currentNews.thumb;
    contentvc.author = currentNews.aid;
    [self.stackController pushViewController:contentvc animated:YES];
}


#pragma mark - layoutSubviews

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if (!self.lastVC) {
        self.lastVC = self.tabBarController.selectedViewController;
    }
}

@end
