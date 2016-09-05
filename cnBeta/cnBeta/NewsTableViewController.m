//
//  NewsTableViewController.m
//  cnBeta
//
//  Created by hudy on 16/6/19.
//  Copyright © 2016年 hudy. All rights reserved.
//

#define SCREEN_WIDTH                    ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT                   ([UIScreen mainScreen].bounds.size.height)

#import "NewsTableViewController.h"
#import "MJRefresh.h"
#import "UIViewController+DownloadNews.h"
#import "UIView+isShowingOnScreen.h"
#import "contentViewController.h"
#import "NewsListCell.h"
#import "MJExtension.h"
#import "AFNetworking.h"
#import "SDCycleScrollView.h"
#import "DataModel.h"
#import "CycleNewsModel.h"
#import "FileCache.h"
#import "DataBase.h"



@interface NewsTableViewController ()<SDCycleScrollViewDelegate>
@property (nonatomic, assign) NSUInteger RowCount;
@property (nonatomic, strong) NSMutableArray *newsList;
@property (nonatomic, strong) NSArray *cycleNews;
@property (nonatomic, strong) NSMutableArray *imagesArray;
@property (nonatomic, strong) NSMutableArray *titlesArray;
@property (nonatomic, strong) FileCache *fileCache;
@property (nonatomic, strong) DataBase *collection;

@property (nonatomic, strong) UIViewController *lastVC;
@end

@implementation NewsTableViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
    //self.navigationItem.title = @"cnBeta新闻";
    //self.tabBarItem.title = [NSString stringWithFormat:@"资讯"];
    self.tableView.rowHeight = 80.0f;
    self.tableView.separatorColor = [UIColor grayColor];
    self.tableView.tableFooterView=[[UIView alloc]init];
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
        
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)])  {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    //_RowCount = 20;
    self.newsList = [[NSMutableArray alloc]init];
    
    _fileCache = [FileCache sharedCache];
    _collection = [DataBase sharedDataBase];
    [self loadCache];
    
    //监听点击TabBar的通知
    //NSLog(@"%@", self.tabBarController.selectedViewController);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tabBarClick) name:@"TabRefresh" object:nil];
    
    [self initCycleView];
    [self setupRefreshView];
    [self setupDataBase];
    
    //[self tabBarClick];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLoad"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //self.navigationController.hidesBarsOnSwipe = YES;
    
    [self.tableView reloadData];
}

- (NSMutableArray *)imagesArray
{
    if (!_imagesArray) {
        _imagesArray = [NSMutableArray array];
    }
    return _imagesArray;
}

- (NSMutableArray *)titlesArray
{
    if (!_titlesArray) {
        _titlesArray = [NSMutableArray array];
    }
    return _titlesArray;
}

- (void)loadCache
{
    NSMutableArray *newslist = [_fileCache getNewsListFromFileForKey:@"newsList"];
    if (newslist) {
        self.newsList = newslist;
        self.RowCount = [self.newsList count];
        
//        SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH *0.55) imageURLStringsGroup:nil];
//        cycleScrollView.delegate = self;
//        cycleScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentRight;
//        cycleScrollView.titlesGroup = nil;
//        cycleScrollView.pageControlStyle = SDCycleScrollViewPageContolStyleClassic;
//        //cycleScrollView.autoScrollTimeInterval = 6.0;
//        self.tableView.tableHeaderView = cycleScrollView;
        [self.tableView reloadData];
    }

}

- (void)initCycleView
{
    [self requestWithURLType:@"cycle" completion:^(id data, NSError *error) {
        if (!error) {
            NSArray *dataList = [CycleNewsModel mj_objectArrayWithKeyValuesArray:data[@"data"][@"hot"]];
            self.cycleNews = dataList;
            NSMutableArray *imagesArray = [NSMutableArray array];
            NSMutableArray *titlesArray = [NSMutableArray array];
            for (CycleNewsModel *data in dataList) {
                [imagesArray addObject:[data.images count]? data.images[0] : @"http://betanews.com/wp-content/uploads/2016/07/bitcoin-halvening.jpg"] ;
                if (!data.images.count) {
                    [data.images addObject:@"http://betanews.com/wp-content/uploads/2016/07/bitcoin-halvening.jpg"];
                }
                [titlesArray addObject:data.title];
            }
            [self.imagesArray addObjectsFromArray:imagesArray];
            [self.titlesArray addObjectsFromArray:titlesArray];
            
            SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH *0.55) imageURLStringsGroup:self.imagesArray];
            cycleScrollView.delegate = self;
            cycleScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentRight;
            cycleScrollView.titlesGroup = self.titlesArray;
            cycleScrollView.pageControlStyle = SDCycleScrollViewPageContolStyleClassic;
            cycleScrollView.autoScrollTimeInterval = 6.0;
            self.tableView.tableHeaderView = cycleScrollView;
        }
    }];
    
    
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
    [self requestWithURLType:@"updatedNews" completion:^(id data, NSError *error) {
        if (!error) {
            //NSLog(@"%@",dataDic[@"lists"]);
            
            NSArray *dataList = [DataModel mj_objectArrayWithKeyValuesArray:data[@"result"]];
            [self.newsList removeAllObjects];
            [self.newsList addObjectsFromArray:dataList];
            self.RowCount = [self.newsList count];
            [self.tableView reloadData];
            [self.tableView.mj_header endRefreshing];
            //FileCache *fileCache = [FileCache sharedCache];
            [_fileCache cacheNewsListToFile:self.newsList forKey:@"newsList"];
        }else {
            [self.tableView.mj_header endRefreshing];
        }
    }];
    
}


- (void)footerRefresh
{
    NSString *sid = [[_newsList lastObject]sid];
    
    [self requestWithURLType:@"moreNews" andId:sid completion:^(id data, NSError *error) {
        if (!error) {
            //NSLog(@"%@",dataDic);
            NSArray *dataList = [DataModel mj_objectArrayWithKeyValuesArray:data[@"result"]];
            [self.newsList addObjectsFromArray:dataList];
            self.RowCount = [self.newsList count];
            [self.tableView reloadData];
            [self.tableView.mj_footer endRefreshing];
        }else {
            [self.tableView.mj_footer endRefreshing];
        }
        
    }];
    
}

#pragma mark - DataBase

- (void)setupDataBase
{
    
    [_collection createDataBase];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.RowCount;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewsListCell *cell = [NewsListCell cellWithTableView:tableView];
    
    DataModel *dataModel = _newsList[indexPath.row];
    cell.newsModel = dataModel;
    
    //判断新闻是否已读
    if ([_collection queryWithSid:dataModel.sid tableType:@"newsID"]) {
        cell.newstitle.textColor = [UIColor grayColor];
    } else {
        if ([dataModel.comments intValue] >= 30) {
            cell.newstitle.textColor = [UIColor redColor];
        }else {
            cell.newstitle.textColor = [UIColor blackColor];
        }
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]){
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    return cell;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    if ([segue.destinationViewController isKindOfClass:[contentViewController class]]) {
//        contentViewController *contentvc = (contentViewController *)segue.destinationViewController;
//        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//        contentvc.hidesBottomBarWhenPushed = YES;
//        DataModel *currentNews = self.newsList[indexPath.row];
//        contentvc.newsId = currentNews.sid;
//        contentvc.newsTitle = currentNews.title;
//        contentvc.thumb = currentNews.thumb;
//        [_collection addNewsID:currentNews.sid];
//        
//    }
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DataModel *currentNews = self.newsList[indexPath.row];
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    contentViewController *contentvc = [mainStoryboard instantiateViewControllerWithIdentifier:@"contentViewController"];
    contentvc.newsId = currentNews.sid;
    contentvc.newsTitle = currentNews.title;
    contentvc.thumb = currentNews.thumb;
    
    contentvc.hidesBottomBarWhenPushed = YES;
    
    [_collection addNewsID:currentNews.sid];

    [self.navigationController pushViewController:contentvc animated:YES];
    
}


#pragma mark - CycleScrollView delegate

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
    CycleNewsModel *data = self.cycleNews[index];
    //contentViewController *contentVC = [self.storyboard instantiateViewControllerWithIdentifier:@"contentVC"];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    contentViewController *contentVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"contentViewController"];
    contentVC.hidesBottomBarWhenPushed = YES;
    contentVC.newsId = data.id;
    contentVC.newsTitle = data.title;
    contentVC.thumb = data.images[0];
    [self.navigationController pushViewController:contentVC animated:YES];
}



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
