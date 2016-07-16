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
#import "SDRefresh.h"
#import "UIViewController+DownloadNews.h"
#import "contentViewController.h"
#import "NewsListCell.h"
#import "MJExtension.h"
#import "AFNetworking.h"
#import "SDCycleScrollView.h"
#import "DataModel.h"
#import "CycleNewsModel.h"
#import "FileCache.h"
#import "DataBase.h"

static NSString *const newsListURLString = @"http://cnbeta.techoke.com/api/list?version=1.8.6&init=1";



@interface NewsTableViewController ()<SDCycleScrollViewDelegate>
@property (nonatomic, assign) NSUInteger RowCount;
@property (nonatomic, weak) SDRefreshHeaderView *refreshHeader;
@property (nonatomic, weak) SDRefreshFooterView *refreshFooter;
@property (nonatomic, strong) NSMutableArray *newsList;
@property (nonatomic, strong) NSArray *cycleNews;
@property (nonatomic, strong) NSMutableArray *imagesArray;
@property (nonatomic, strong) NSMutableArray *titlesArray;
@property (nonatomic, strong) FileCache *fileCache;
@property (nonatomic, strong) DataBase *collection;
@end

@implementation NewsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
    self.navigationItem.title = @"cnBeta新闻";
    self.tabBarItem.title = [NSString stringWithFormat:@"资讯"];
    self.tableView.rowHeight = 90.0f;
    self.tableView.separatorColor = [UIColor grayColor];
    //_RowCount = 20;
    self.newsList = [[NSMutableArray alloc]init];
    
    _fileCache = [FileCache sharedCache];
    _collection = [DataBase sharedDataBase];
    [self loadCache];
    
    [self initTableView];
    [self setupHeader];
    [self setupFooter];
    [self setupDataBase];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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

- (void)initTableView
{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:newsListURLString parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *dataList = [CycleNewsModel mj_objectArrayWithKeyValuesArray:responseObject[@"data"][@"hot"]];
        self.cycleNews = dataList;
        NSMutableArray *imagesArray = [NSMutableArray array];
        NSMutableArray *titlesArray = [NSMutableArray array];
        for (CycleNewsModel *data in dataList) {
            [imagesArray addObject:[data.images count]? data.images[0] : @"http://betanews.com/wp-content/uploads/2016/07/bitcoin-halvening.jpg"] ;
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
        //[_fileCache cacheObjectArrayToFile:self. forKey:<#(NSString *)#>]

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
//    [self requestWithURL:newsListURLString completion:^(NSData *data, NSError *error) {
//        if (!error) {
//            NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil][@"data"];
//            //NSLog(@"%@",dataDic[@"lists"]);
//            NSArray *dataList = [CycleNewsModel mj_objectArrayWithKeyValuesArray:dataDic[@"hot"]];
//            self.cycleNews = dataList;
//            NSMutableArray *imagesArray = [NSMutableArray array];
//            NSMutableArray *titlesArray = [NSMutableArray array];
//            for (CycleNewsModel *data in dataList) {
//                [imagesArray addObject:data.images[0]];
//                [titlesArray addObject:data.title];
//            }
//            [self.imagesArray addObjectsFromArray:imagesArray];
//            [self.titlesArray addObjectsFromArray:titlesArray];
//            
//            SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH *0.55) imageURLStringsGroup:self.imagesArray];
//            cycleScrollView.delegate = self;
//            cycleScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentRight;
//            cycleScrollView.titlesGroup = self.titlesArray;
//            cycleScrollView.pageControlStyle = SDCycleScrollViewPageContolStyleClassic;
//            cycleScrollView.autoScrollTimeInterval = 6.0;
//            self.tableView.tableHeaderView = cycleScrollView;
//        }
//    }];
    
    
}

- (void)setupHeader
{
    SDRefreshHeaderView *refreshHeader = [SDRefreshHeaderView refreshView];
    [refreshHeader addToScrollView:self.tableView];
    _refreshHeader = refreshHeader;
    __weak typeof(self) weakSelf = self;
    refreshHeader.beginRefreshingOperation = ^{
        [weakSelf requestWithURLType:@"updatedNews" completion:^(id data, NSError *error) {
            if (!error) {
                //NSLog(@"%@",dataDic[@"lists"]);
                
                NSArray *dataList = [DataModel mj_objectArrayWithKeyValuesArray:data[@"result"]];
                [weakSelf.newsList removeAllObjects];
                [weakSelf.newsList addObjectsFromArray:dataList];
                weakSelf.RowCount = [weakSelf.newsList count];
                [weakSelf.tableView reloadData];
                [_refreshHeader endRefreshing];
                //FileCache *fileCache = [FileCache sharedCache];
                [_fileCache cacheNewsListToFile:weakSelf.newsList forKey:@"newsList"];
            }
        }];
        
    };
    
    //[self loadData];
    [refreshHeader autoRefreshWhenViewDidAppear];
}


- (void)setupFooter
{
    SDRefreshFooterView *refreshFooter = [SDRefreshFooterView refreshView];
    [refreshFooter addToScrollView:self.tableView];
    [refreshFooter addTarget:self refreshAction:@selector(footerRefresh)];
    _refreshFooter = refreshFooter;
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
            [self.refreshFooter endRefreshing];
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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"NewsCell";
    NewsListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    DataModel *dataModel = _newsList[indexPath.row];
    cell.newsModel = dataModel;
    if ([_collection queryWithSid:dataModel.sid tableType:@"newsID"]) {
        cell.newstitle.textColor = [UIColor grayColor];
    }
    
    
    //cell.textLabel.numberOfLines = 3;
    //cell.textLabel.attributedText = [[NSAttributedString alloc] initWithData:[self.newsList[indexPath.row][@"title"] dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    // Configure the cell...
    
    return cell;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[contentViewController class]]) {
        contentViewController *contentvc = (contentViewController *)segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        contentvc.hidesBottomBarWhenPushed = YES;
        DataModel *currentNews = self.newsList[indexPath.row];
        contentvc.newsId = currentNews.sid;
        contentvc.comments = currentNews.comments;
        contentvc.newsTitle = currentNews.title;

        [_collection addNewsID:currentNews.sid];
        
//        contentvc.contentURL = [contentBaseURLString stringByAppendingString:[NSString stringWithFormat:@"%@&timestamp=%llu&v=1.0&mpuffgvbvbttn3Rc&sign=%@", sid, timestamp, sign]];
        //NSLog(@"%@",contentURLString);
        
        
    }
}


#pragma mark - CycleScrollView delegate

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
    CycleNewsModel *data = self.cycleNews[index];
    contentViewController *contentVC = [self.storyboard instantiateViewControllerWithIdentifier:@"contentVC"];
    contentVC.hidesBottomBarWhenPushed = YES;
    contentVC.newsId = data.id;
    [self.navigationController pushViewController:contentVC animated:YES];
}

























@end
