//
//  NewsTableViewController.m
//  cnBeta
//
//  Created by hudy on 16/6/19.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "NewsTableViewController.h"
#import "SDRefresh.h"
#import "UIViewController+DownloadNews.h"
#import "contentViewController.h"
#import "NewsListCell.h"
#import "DataModel.h"
#import "MJExtension.h"

static NSString *const newsListURLString = @"http://cnbeta.techoke.com/api/list?version=1.8.6&init=1";
static NSString *const loadNewsListBaseURLString = @"http://cnbeta.techoke.com/api/list?version=1.8.6&last=";


@interface NewsTableViewController ()
@property (nonatomic, assign) NSUInteger RowCount;
@property (nonatomic, weak) SDRefreshHeaderView *refreshHeader;
@property (nonatomic, weak) SDRefreshFooterView *refreshFooter;
@property (nonatomic, strong) NSMutableArray *newsList;
//@property (nonatomic, strong) NSDictionary *content;
@end

@implementation NewsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
    self.navigationItem.title = @"cnBeta新闻";
    self.tabBarItem.title = [NSString stringWithFormat:@"新闻列表"];
    self.tableView.rowHeight = 90.0f;
    self.tableView.separatorColor = [UIColor grayColor];
    //_RowCount = 20;
    self.newsList = [[NSMutableArray alloc]init];
    [self setupHeader];
    [self setupFooter];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)setupHeader
{
    SDRefreshHeaderView *refreshHeader = [SDRefreshHeaderView refreshView];
    [refreshHeader addToScrollView:self.tableView];
    
    __weak SDRefreshHeaderView *weakRefreshHeader = refreshHeader;
    __weak typeof(self) weakSelf = self;
    refreshHeader.beginRefreshingOperation = ^{
        [weakSelf freshData:newsListURLString];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //[weakSelf loadData:newsListURLString];
            [weakSelf.tableView reloadData];
            [weakRefreshHeader endRefreshing];
        });
        
    };
    
    //[self loadData];
    [refreshHeader autoRefreshWhenViewDidAppear];
}

- (void)freshData:(NSString *)URLString
{
    [self requestWithURL:URLString completion:^(NSData *data, NSError *error) {
        if (!error) {
            NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil][@"data"];
            //NSLog(@"%@",dataDic[@"lists"]);
            NSArray *dataList = [DataModel mj_objectArrayWithKeyValuesArray:dataDic[@"lists"]];
            [self.newsList removeAllObjects];
            [self.newsList addObjectsFromArray:dataList];
            self.RowCount = [self.newsList count];
        }
        
    }];

}

- (void)loadData:(NSString *)URLString
{
    
        [self requestWithURL:URLString completion:^(NSData *data, NSError *error) {
            if (!error) {
                NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil][@"data"];
                //NSLog(@"%@",dataDic);
                NSArray *dataList = [DataModel mj_objectArrayWithKeyValuesArray:dataDic[@"list"]];
                [self.newsList addObjectsFromArray:dataList];
                self.RowCount = [self.newsList count];
            }
            //[self.tableView reloadData];
            //[self.refreshHeader endRefreshing];
    //        dispatch_async(dispatch_get_main_queue(), ^{
    //            [self.refreshHeader endRefreshing];
    //        });
        }];
        
    
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
    NSString *URLString = [loadNewsListBaseURLString stringByAppendingString:[NSString stringWithFormat:@"%@", [[_newsList lastObject]id]]];
    [self loadData:URLString];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //[self loadData:URLString];
        [self.tableView reloadData];
        [self.refreshFooter endRefreshing];
    });
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
        contentvc.newsId = currentNews.id;
//        NSString *sid = self.newsList[indexPath.row][@"id"];
//        //NSString *sid = @"512827";
//        
//        //Unix时间戳
//        UInt64 timestamp = (UInt64)[[NSDate date]timeIntervalSince1970];
//        //UInt64 timestamp = 1466565768;
//        
//        //md5加密
//        NSString *md5String = [NSString stringWithFormat:@"app_key=10000&format=json&method=Article.NewsContent&sid=%@&timestamp=%llu&v=1.0&mpuffgvbvbttn3Rc", sid, timestamp ];
//        NSString *sign = [md5String MD5];
//        
//        contentvc.contentURL = [contentBaseURLString stringByAppendingString:[NSString stringWithFormat:@"%@&timestamp=%llu&v=1.0&mpuffgvbvbttn3Rc&sign=%@", sid, timestamp, sign]];
        //NSLog(@"%@",contentURLString);
        
        
    }
}


























@end
