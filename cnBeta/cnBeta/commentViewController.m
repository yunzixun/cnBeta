//
//  commentViewController.m
//  cnBeta
//
//  Created by hudy on 16/7/7.
//  Copyright © 2016年 hudy. All rights reserved.
//

#define SCREEN_WIDTH                    ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT                   ([UIScreen mainScreen].bounds.size.height)

#import "commentViewController.h"
#import "SDRefresh.h"
#import "UIViewController+DownloadNews.h"
#import "commentList.h"
#import "commentModel.h"
#import "commentCell.h"
#import "MJExtension.h"
#import "UITableView+FDTemplateLayoutCell.h"

@interface commentViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong)UITableView *commentTableView;
@property (nonatomic, weak) SDRefreshHeaderView *refreshHeader;
@property (nonatomic, copy)NSString *sid;
@property (nonatomic, copy)NSString *sn;
@property (nonatomic, strong)NSMutableArray *commentArray;
@property (nonatomic, strong)NSMutableArray *hotNews;

@end

@implementation commentViewController

- (NSMutableArray *)commentArray
{
    if (!_commentArray) {
        _commentArray = [NSMutableArray array];
    }
    return _commentArray;
}

- (NSMutableArray *)hotNews
{
    if (!_hotNews) {
        _hotNews = [NSMutableArray array];
    }
    return _hotNews;
}

- (id)initWithSid:(NSString *)sid andSN:(NSString *)sn
{
    if (self = [super init]) {
        _sid = sid;
        _sn = sn;
    }
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"暂不支持评论";
    _commentTableView = [[UITableView alloc] initWithFrame:self.view.frame];
    //_commentTableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    [self.view addSubview:_commentTableView];
    _commentTableView.delegate = self;
    _commentTableView.dataSource = self;
    _commentTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
//    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]init];
//    [self.commentTableView addSubview:spinner];
//    
//    [spinner startAnimating];
//    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
//    spinner.center = CGPointMake(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2 - 100);
//    [spinner setHidesWhenStopped:YES];
    
    
    [_commentTableView registerNib:[UINib nibWithNibName:@"commentCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"newCell"];
    [self setupHeader];
    
    //[LSCommentTool loadCommentListWithSid:self.sid pageNum:[NSString stringWithFormat:@"%tu",self.pageNum] SN:self.sn success:^(NSArray *commentArray) {

}

- (void)setupHeader
{
    SDRefreshHeaderView *refreshHeader = [SDRefreshHeaderView refreshView];
    [refreshHeader addToScrollView:self.commentTableView];
    _refreshHeader = refreshHeader;
    __weak typeof(self) weakSelf = self;
    refreshHeader.beginRefreshingOperation = ^{
        [weakSelf loadCommentListWithSid:_sid SN:_sn success:^(NSArray *commentArray, NSArray *hotNews) {
            [weakSelf.commentArray removeAllObjects];
            [weakSelf.commentArray addObjectsFromArray:commentArray];
            [weakSelf.hotNews removeAllObjects];
            [weakSelf.hotNews addObjectsFromArray:hotNews];
            //[spinner stopAnimating];
            [weakSelf.commentTableView reloadData];
            [_refreshHeader endRefreshing];
        } failure:^(NSError *error) {
            NSLog(@"%@",error);
        }];
        
    };
    [refreshHeader autoRefreshWhenViewDidAppear];
}



- (void)loadCommentListWithSid:(NSString *)sid SN:(NSString *)sn success:(void (^)(NSArray *, NSArray *))success failure:(void(^)(NSError * error))failure{
    NSString *url = [NSString stringWithFormat:@"http://www.cnbeta.com/cmt?op=1,%@,%@", sid, sn];
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [headers setObject:@"XMLHttpRequest" forKey:@"X-Requested-With"];
    [headers setObject:@"http://www.cnbeta.com/" forKey:@"Referer"];
    
    
    [self requestWithURL:url andHeaders:headers completion:^(id data, NSError *error) {
        if (!error) {
            //NSLog(@"%@", data[@"result"]);
            NSArray *cmList = [commentList mj_objectArrayWithKeyValuesArray:data[@"result"][@"cmntlist"]];
            NSArray * hotlist = [commentList mj_objectArrayWithKeyValuesArray:data[@"result"][@"hotlist"]];
            
            NSMutableArray *commentArray = [NSMutableArray array];
            NSMutableArray *hotNews = [NSMutableArray array];
            
            for (commentList *temp in cmList) {
                commentModel* comment = [commentModel mj_objectWithKeyValues:data[@"result"][@"cmntstore"][temp.tid]];
                [commentArray addObject:comment];
            }
            for (commentList *temp in hotlist) {
                commentModel* comment = [commentModel mj_objectWithKeyValues:data[@"result"][@"cmntstore"][temp.tid]];
                [hotNews addObject:comment];
            }
            if (success) {
                success(commentArray, hotNews);
            }
        } else {
            if (failure) {
                failure(error);
            }
        }
        
    }];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.hotNews count]) {
        return 2;
    }else {
        return 1;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.hotNews count]) {
        if (section == 0) {
            return [self.hotNews count];
        } else {
            return [self.commentArray count];
        }
    } else {
        return [self.commentArray count];
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    commentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"newCell" forIndexPath:indexPath];
    if ([self.hotNews count]) {
        if (indexPath.section ==0) {
            cell.commentInfo = _hotNews[indexPath.row];
            cell.floor.text = nil;
        } else {
            cell.commentInfo = _commentArray[indexPath.row];
            cell.floor.text = [NSString stringWithFormat:@"%lu楼", [self.commentArray count]-indexPath.row];
        }
    }else {
        cell.commentInfo = _commentArray[indexPath.row];
        cell.floor.text = [NSString stringWithFormat:@"%lu楼", [self.commentArray count]-indexPath.row];
    }
    
    //NSLog(@"%ld", (long)indexPath.row);
    // Configure the cell...return
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    commentModel *comment;
    if ([self.hotNews count]) {
        if (indexPath.section ==0) {
            comment = _hotNews[indexPath.row];
        } else {
            comment = _commentArray[indexPath.row];
        }
    } else {
        comment = _commentArray[indexPath.row];
    }

    
    //commentModel *comment = _commentArray[indexPath.row];
    
    return [_commentTableView fd_heightForCellWithIdentifier:@"newCell" cacheByIndexPath:indexPath configuration:^(id cell) {
        [cell setCommentInfo:comment];
    }];
    
}

//- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    if (section == 0) {
//        return @"热门评论";
//    } else {
//        return @"全部评论";
//    }
//}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, 300.0, 44.0)];
    
    UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.opaque = NO;
    
    headerLabel.highlightedTextColor = [UIColor whiteColor];
    headerLabel.font = [UIFont systemFontOfSize:14];
    headerLabel.frame = CGRectMake(10.0, 0.0, 300.0, 25.0);
    
    if ([self.hotNews count]) {
        if (section == 0) {
            headerLabel.text =  @"热门评论";
            headerLabel.textColor = [UIColor redColor];
        }else {
            headerLabel.text = @"全部评论";
            headerLabel.textColor = [UIColor blueColor];
        }
    }else {
        headerLabel.text = @"全部评论";
    }
    
    [customView addSubview:headerLabel];
    
    return customView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 25;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
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
