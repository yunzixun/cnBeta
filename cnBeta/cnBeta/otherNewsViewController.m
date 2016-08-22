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
#import "UIViewController+DownloadNews.h"
#import "UIView+isShowingOnScreen.h"

#import "HotNewsModel.h"
#import "contentViewController.h"
#import "NewsListCell.h"



@interface otherNewsViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, assign) NSUInteger RowCount;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, assign) int page;

@property (nonatomic, strong) UIViewController *lastVC;
@end

@implementation otherNewsViewController

- (NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc]init];
    }
    return _dataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
    
    self.page = 1;
    [self initTableView];
    [self setupRefreshView];
    
    //监听点击TabBar的通知
    self.lastVC = self.tabBarController.selectedViewController;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tabBarClick) name:@"TabRefresh" object:nil];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLoad"];
}

- (void)initTableView
{
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 64 - 49) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    self.tableView.rowHeight = 80.0f;
    self.tableView.separatorColor = [UIColor grayColor];
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
    NSString *url = [NSString stringWithFormat:@"http://www.cnbeta.com/more?type=%@&page=1", self.type];
    NSMutableDictionary *headers = [[NSMutableDictionary alloc]init];
    [headers setObject:@"http://www.cnbeta.com/" forKey:@"Referer"];
    [self requestWithURL:url andHeaders:headers completion:^(id data, NSError *error) {
        if (!error) {
            //NSLog(@"%@",data[@"result"]);
            NSArray *dataList = [HotNewsModel mj_objectArrayWithKeyValuesArray:data[@"result"][@"list"]];
            [self.dataSource removeAllObjects];
            [self.dataSource addObjectsFromArray:dataList];
            self.RowCount = [self.dataSource count];
            [self.tableView reloadData];
            [self.tableView.mj_header endRefreshing];
        }else {
            [self.tableView.mj_header endRefreshing];
        }
    }];
}


- (void)footerRefresh
{
    self.page ++;
    NSString *url = [NSString stringWithFormat:@"http://www.cnbeta.com/more?type=%@&page=%d", self.type, self.page];
    NSMutableDictionary *headers = [[NSMutableDictionary alloc]init];
    [headers setObject:@"http://www.cnbeta.com/" forKey:@"Referer"];
    [self requestWithURL:url andHeaders:headers completion:^(id data, NSError *error) {
        if (!error) {
            NSArray *dataList = [HotNewsModel mj_objectArrayWithKeyValuesArray:data[@"result"][@"list"]];
            [self.dataSource addObjectsFromArray:dataList];
            self.RowCount = [self.dataSource count];
            [self.tableView reloadData];
            [self.tableView.mj_footer endRefreshing];
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
    NewsListCell *cell = [NewsListCell cellWithTableView:tableView];
    cell.hotNewsModel = self.dataSource[indexPath.row];
    
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
    HotNewsModel *currentNews= _dataSource[indexPath.row];
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    contentViewController *contentvc = [mainStoryboard instantiateViewControllerWithIdentifier:@"contentViewController"];
    contentvc.newsId = currentNews.sid;
    contentvc.newsTitle = currentNews.title;
    contentvc.thumb = currentNews.thumb;
    
    contentvc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:contentvc animated:YES];
}


#pragma mark - layoutSubviews

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:@"firstLoad"]) {
        self.lastVC = self.tabBarController.selectedViewController;
        [defaults setBool:NO forKey:@"firstLoad"];
    }
}

@end
