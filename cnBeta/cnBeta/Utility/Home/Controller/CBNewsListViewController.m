//
//  CBNewsListViewController.m
//  cnBeta
//
//  Created by hudy on 2017/1/15.
//  Copyright © 2017年 hudy. All rights reserved.
//

#import "CBNewsListViewController.h"
#import "SDCycleScrollView.h"
#import "CBNewsListTableView.h"
#import "contentViewController.h"
#import "MJRefresh.h"
#import "CBHTTPRequester.h"
#import "UIView+isShowingOnScreen.h"
#import "CBNewsListCell.h"
#import "CBPadNewsListCell.h"
#import "AFNetworking.h"
#import "MJExtension.h"
#import "NewsModel.h"
#import "CycleNewsModel.h"
#import "CBDataBase.h"
#import "CBAppSettings.h"
#import "WKProgressHUD.h"
#import "NewPagedFlowView.h"
#import "PGIndexBannerSubiew.h"

static CGFloat kTabbarHeight = 49.0f;

@interface CBNewsListViewController ()<SDCycleScrollViewDelegate,UITableViewDelegate,UITableViewDataSource, NewPagedFlowViewDelegate, NewPagedFlowViewDataSource>

@property (nonatomic, assign) NSUInteger RowCount;
@property (nonatomic, strong) NSMutableArray *newsList;
@property (nonatomic, strong) NSArray *cycleNews;
@property (nonatomic, strong) NSArray *bannerImageURLs;
@property (nonatomic, copy)   NSString *type;
@property (nonatomic, assign) int page;
@property (nonatomic, strong) CBNewsListTableView *tableView;
@property (nonatomic, strong) NewPagedFlowView *pageFlowView;
@property (nonatomic, weak) UIViewController *lastVC;

@end

@implementation CBNewsListViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    //    backItem.title = @"返回";
    //    self.navigationItem.backBarButtonItem = backItem;
    //self.navigationItem.title = @"cnBeta新闻";
    //self.tabBarItem.title = [NSString stringWithFormat:@"资讯"];
    self.page = 1;
    self.type = @"all";
    
    //_RowCount = 20;
    self.newsList = [[NSMutableArray alloc]init];
    [self initTableView];
    [self loadCache];
    
    //监听点击TabBar的通知
    //NSLog(@"%@", self.tabBarController.selectedViewController);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tabBarClick) name:@"TabRefresh" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged) name:CBAppSettingThemeChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadAfterFontChanged) name:CBAppSettingFontChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadAfterPrefetchEnabled) name:CBPrefetchEnabledNotification object:nil];
    [self setupRefreshView];
    if ([CBAppSettings sharedSettings].updateNotificationEnabled) {
        [self checkVersion];
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if (!self.lastVC) {
        self.lastVC = self.tabBarController.selectedViewController;
    }
}

- (void)themeChanged
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (isPad) {
            self.pageFlowView.backgroundColor = [UIColor cb_newsTableViewBackgroundColor];
        }
        [self.tableView reloadData];
    });
}

- (void)reloadAfterFontChanged
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (isPad) {
            [self.pageFlowView reloadData];
        } else {
            [(SDCycleScrollView *)self.tableView.tableHeaderView refreshTitleFont];
        }
        [self.tableView reloadData];
    });
}

- (void)reloadAfterPrefetchEnabled
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


- (void)checkVersion
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([AFNetworkReachabilityManager sharedManager].isReachable) {
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://github.com/hudyseu/cnBeta/blob/master/cnBeta/screenshots/version"]];
            NSString *file = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if (file.length>0) {
                NSRange range1 = [file rangeOfString:@"newVersion:"];
                NSString *fileSeg = [file substringFromIndex:range1.location + range1.length];
                NSRange range2 = [fileSeg rangeOfString:@"<"];
                NSString *version = [fileSeg substringWithRange:NSMakeRange(0, range2.location)];
                
                NSDictionary *infoDictionary = [[NSBundle mainBundle]infoDictionary];
                NSString *lastVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
                if (lastVersion.length > 3) {
                    lastVersion = [[lastVersion substringToIndex:3] stringByAppendingString:[lastVersion substringFromIndex:4]];
                }
                if (version.floatValue > lastVersion.floatValue) {
                    [self alertView:@"新版本！"message:nil cancel:@"取消"];
                }
            }
        }
    });
}

- (void)alertView:(NSString *)alertString message:(NSString *)msg cancel:(NSString *)action
{
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:alertString message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *leftButton = [UIAlertAction actionWithTitle:action style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *rightButton = [UIAlertAction actionWithTitle:@"更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:cnBeta_APP_STORE_URL]];
    }];
    [alertView addAction:leftButton];
    if ([action isEqual: @"取消"]) {
        [alertView addAction:rightButton];
    }
    [self presentViewController:alertView animated:YES completion:nil];
}


- (void)loadCache
{
    NSArray *newslist = [[CBDataBase sharedDataBase] newsListWithLastNews:nil limit:40];
    if (newslist.count > 0) {
        [self.newsList addObjectsFromArray:newslist];
        self.RowCount = [self.newsList count];
    }
    
}

- (void)initCycleView
{
    [[CBHTTPRequester requester] requestWithURLType:@"cycle" completion:^(id data, NSError *error) {
        if (!error) {
            NSArray *dataList = [CycleNewsModel mj_objectArrayWithKeyValuesArray:data[@"data"][@"hot"]];
            self.cycleNews = dataList;
            NSMutableArray *imagesArray = [NSMutableArray array];
            NSMutableArray *titlesArray = [NSMutableArray array];
            for (CycleNewsModel *data in dataList) {
                [imagesArray addObject:[data.images count]? data.images[0] : @"hp://betanews.com/wp-content/uploads/2016/07/bitcoin-halvening.jpg"] ;
                if (!data.images.count) {
                    [data.images addObject:@"http://betanews.com/wp-content/uploads/2016/07/bitcoin-halvening.jpg"];
                }
                [titlesArray addObject:data.title];
            }
            self.bannerImageURLs = imagesArray;
            
            if (!isPad) {
                
                /**
                 *  手机上的轮播
                 */
                SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenWidth *0.55) imageURLStringsGroup:imagesArray];
                cycleScrollView.delegate = self;
                cycleScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentRight;
                cycleScrollView.titlesGroup = titlesArray;
                cycleScrollView.pageControlStyle = SDCycleScrollViewPageContolStyleClassic;
                cycleScrollView.autoScrollTimeInterval = 6.0;
                self.tableView.tableHeaderView = cycleScrollView;
                [cycleScrollView startloading];
                
            } else {
                
                /**
                 *  平板上的轮播
                 */
                NewPagedFlowView *pageFlowView = [[NewPagedFlowView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, (ScreenWidth*3/5) * 9 / 16 + 24)];
                self.pageFlowView = pageFlowView;
                pageFlowView.delegate = self;
                pageFlowView.dataSource = self;
                pageFlowView.minimumPageAlpha = 0.1;
                pageFlowView.minimumPageScale = 0.85;
                pageFlowView.isCarousel = YES;
                pageFlowView.orientation = NewPagedFlowViewOrientationHorizontal;
                
                //提前告诉有多少页
                pageFlowView.orginPageCount = imagesArray.count;
                
                pageFlowView.isOpenAutoScroll = YES;
                
                //初始化pageControl
                UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, pageFlowView.frame.size.height - 8, ScreenWidth, 8)];
                pageControl.currentPageIndicatorTintColor = globalColor;
                pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
                pageFlowView.pageControl = pageControl;
                [pageFlowView addSubview:pageControl];
                
                
                UIScrollView *bottomScrollView = [[UIScrollView alloc] initWithFrame:pageFlowView.bounds];
                [bottomScrollView addSubview:pageFlowView];
                [pageFlowView reloadData];
                self.tableView.tableHeaderView = bottomScrollView;
            }
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
    //self.page = 1;
    [self initCycleView];
    
    NSString *url = [NSString stringWithFormat:@"http://www.cnbeta.com/more?type=%@&page=1", self.type];
    NSMutableDictionary *headers = [[NSMutableDictionary alloc]init];
    [headers setObject:@"http://www.cnbeta.com/" forKey:@"Referer"];
    [[CBHTTPRequester requester] fetchNewsListWithURL:url andHeaders:headers completion:^(NSError *error) {
        [self.tableView.mj_header endRefreshing];
        if (error) {
            [WKProgressHUD popMessage:error.userInfo[@"NSLocalizedDescription"] inView:self.view duration:1.5 animated:YES];
            return;
        }
        NSArray *newsArr = [[CBDataBase sharedDataBase] newsListWithLastNews:nil limit:40];
        [self.newsList removeAllObjects];
        [self.newsList addObjectsFromArray:newsArr];
        self.RowCount = [self.newsList count];
        [self.tableView reloadData];
    }];
}


- (void)footerRefresh
{
    NSString *url = [NSString stringWithFormat:@"http://www.cnbeta.com/more?type=%@&page=%d", self.type, self.page];
    NSMutableDictionary *headers = [[NSMutableDictionary alloc]init];
    [headers setObject:@"http://www.cnbeta.com/" forKey:@"Referer"];
    [[CBHTTPRequester requester] fetchNewsListWithURL:url andHeaders:headers completion:^(NSError *error) {
        if (!error) {
            self.page ++;
        }
        
        //if (error && error.code == NSURLErrorTimedOut) {
        if (error && [AFNetworkReachabilityManager sharedManager].isReachable) {

        } else {
            NSArray *newsArr = [[CBDataBase sharedDataBase] newsListWithLastNews:[self.newsList lastObject] limit:40];
            
            [self.newsList addObjectsFromArray:newsArr];
            self.RowCount = [self.newsList count];
            [self.tableView reloadData];
        }
        [self.tableView.mj_footer endRefreshing];
    }];
    
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
    
    CBTableViewCell *cell = isPad ? [CBPadNewsListCell cellWithTableView:tableView] : [CBNewsListCell cellWithTableView:tableView];
    
    NewsModel *news = _newsList[indexPath.row];
    cell.newsModel = news;
    
    if (!news.read && [news.comments intValue] >= 30) {
        cell.titleColor = [UIColor redColor];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
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
    NewsModel *currentNews = self.newsList[indexPath.row];
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
    //contentvc.hidesBottomBarWhenPushed = YES;
    
    
    [self.stackController pushViewController:contentvc animated:YES];
}


#pragma mark - CycleScrollView delegate

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
    CycleNewsModel *data = self.cycleNews[index];
    //contentViewController *contentVC = [self.storyboard instantiateViewControllerWithIdentifier:@"contentVC"];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    contentViewController *contentVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"contentViewController"];
    contentVC.newsId = data.id;
    contentVC.thumb = data.images[0];
    [self.stackController pushViewController:contentVC animated:YES];
}

#pragma mark NewPagedFlowView Delegate
- (CGSize)sizeForPageInFlowView:(NewPagedFlowView *)flowView {
    return CGSizeMake(ScreenWidth*3/5, (ScreenWidth*3/5) * 9 / 16);
}

- (void)didSelectCell:(UIView *)subView withSubViewIndex:(NSInteger)subIndex
{
    CycleNewsModel *data = self.cycleNews[subIndex];
    //contentViewController *contentVC = [self.storyboard instantiateViewControllerWithIdentifier:@"contentVC"];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    contentViewController *contentVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"contentViewController"];
    contentVC.newsId = data.id;
    contentVC.thumb = data.images[0];
    [self.stackController pushViewController:contentVC animated:YES];
}

#pragma mark NewPagedFlowView Datasource
- (NSInteger)numberOfPagesInFlowView:(NewPagedFlowView *)flowView {
    
    return 3;
    
}

- (UIView *)flowView:(NewPagedFlowView *)flowView cellForPageAtIndex:(NSInteger)index{
    PGIndexBannerSubiew *bannerView = (PGIndexBannerSubiew *)[flowView dequeueReusableCell];
    if (!bannerView) {
        bannerView = [[PGIndexBannerSubiew alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth*3/5, (ScreenWidth*3/5) * 9 / 16)];
        bannerView.tag = index;
//        bannerView.layer.cornerRadius = 4;
//        bannerView.layer.masksToBounds = YES;
    }
    //在这里下载网络图片
    NSString *urlStr = self.bannerImageURLs[index];
    if ([CBAppSettings sharedSettings].imageWiFiOnlyEnabled && ![[AFNetworkReachabilityManager sharedManager] isReachableViaWiFi]) {
        urlStr = [@"cnbeta://newsList.thumbnail?" stringByAppendingString:urlStr];
        [bannerView.mainImageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"iPhone_FavTableViewCell_320x58_"]];
    } else {
        [bannerView.mainImageView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"iPhone_FavTableViewCell_320x58_"]];
    }

    CycleNewsModel *news = self.cycleNews[index];
    bannerView.title = news.title;
    
    return bannerView;
}


@end
