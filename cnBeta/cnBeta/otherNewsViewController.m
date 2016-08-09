//
//  otherNewsViewController.m
//  cnBeta
//
//  Created by hudy on 16/8/5.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "otherNewsViewController.h"
#import "Constant.h"
#import "SDRefresh.h"
#import "MJExtension.h"
#import "UIViewController+DownloadNews.h"

#import "HotNewsModel.h"
#import "contentViewController.h"
#import "NewsListCell.h"



@interface otherNewsViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, assign) NSUInteger RowCount;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, weak) SDRefreshHeaderView *refreshHeader;
@property (nonatomic, weak) SDRefreshFooterView *refreshFooter;
@property (nonatomic, assign) int page;

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
    [self setupHeader];
    [self setupFooter];
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
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
        
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)])  {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)setupHeader
{
    SDRefreshHeaderView *refreshHeader = [SDRefreshHeaderView refreshView];
    [refreshHeader addToScrollView:self.tableView];
    _refreshHeader = refreshHeader;
    [refreshHeader addTarget:self refreshAction:@selector(headerRefresh)];
    
    [refreshHeader autoRefreshWhenViewDidAppear];
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
            [self.refreshHeader endRefreshing];
        }else {
            [self.refreshHeader endRefreshing];
        }
    }];
}

-(void)setupFooter
{
    SDRefreshFooterView *refreshFooter = [SDRefreshFooterView refreshView];
    [refreshFooter addToScrollView:self.tableView];
    _refreshFooter = refreshFooter;
    [refreshFooter addTarget:self refreshAction:@selector(footerRefresh)];
}

- (void)footerRefresh
{
    NSString *url = [NSString stringWithFormat:@"http://www.cnbeta.com/more?type=%@&page=%d", self.type, self.page];
    NSMutableDictionary *headers = [[NSMutableDictionary alloc]init];
    [headers setObject:@"http://www.cnbeta.com/" forKey:@"Referer"];
    [self requestWithURL:url andHeaders:headers completion:^(id data, NSError *error) {
        if (!error) {
            NSArray *dataList = [HotNewsModel mj_objectArrayWithKeyValuesArray:data[@"result"][@"list"]];
            [self.dataSource addObjectsFromArray:dataList];
            self.RowCount = [self.dataSource count];
            [self.tableView reloadData];
            [self.refreshFooter endRefreshing];
        }else {
            [self.refreshFooter endRefreshing];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
