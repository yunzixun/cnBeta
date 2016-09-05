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
#import "commentPostViewController.h"

#import "commentList.h"
#import "commentModel.h"
#import "flooredCommentModel.h"
#import "commentCell.h"
#import "LayoutCommentView.h"
#import "DYSectionHeader.h"

#import "MJExtension.h"
#import "UIViewController+DownloadNews.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "NSArray+transform.h"
#import "HTTPRequester.h"
#import "JDStatusBarNotification.h"
#import "WKProgressHUD.h"

@interface commentViewController ()<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,replyActionDelegate>
@property (nonatomic, strong)UITableView *commentTableView;
@property (nonatomic, weak) SDRefreshHeaderView *refreshHeader;
@property (nonatomic, copy)NSString *sid;
@property (nonatomic, copy)NSString *sn;
@property (nonatomic,copy)NSString *cellTid;

@property (nonatomic, strong)NSMutableArray *flooredCommentArray;
@property (nonatomic, strong)NSMutableArray *hotFlooredCommentArray;
@property (nonatomic, strong)NSMutableArray *comments;

@end

@implementation commentViewController

- (NSMutableArray *)flooredCommentArray
{
    if (!_flooredCommentArray) {
        _flooredCommentArray = [NSMutableArray array];
    }
    return _flooredCommentArray;
}

- (NSMutableArray *)hotFlooredCommentArray
{
    if (!_hotFlooredCommentArray) {
        _hotFlooredCommentArray = [NSMutableArray array];
    }
    return _hotFlooredCommentArray;
}

- (NSMutableArray *)comments
{
    if (!_comments) {
        _comments = [NSMutableArray array];
    }
    return _comments;
}

- (id)initWithSid:(NSString *)sid andSN:(NSString *)sn Type:(BOOL)isExpired
{
    if (self = [super init]) {
        _sid = sid;
        _sn = sn;
        _isExpired = isExpired;
    }
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"取消";
    self.navigationItem.backBarButtonItem = backItem;
    UIBarButtonItem *commentItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"WriteComment"] style:UIBarButtonItemStyleDone target:self action:@selector(postComment)];
    self.navigationItem.rightBarButtonItem = commentItem;
    
    
    _commentTableView = [[UITableView alloc] initWithFrame:self.view.frame];
    //_commentTableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    if ([_commentTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_commentTableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    if ([_commentTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_commentTableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
}

- (void)setupHeader
{
    SDRefreshHeaderView *refreshHeader = [SDRefreshHeaderView refreshView];
    [refreshHeader addToScrollView:self.commentTableView];
    _refreshHeader = refreshHeader;
    __weak typeof(self) weakSelf = self;
    refreshHeader.beginRefreshingOperation = ^{
        [weakSelf loadCommentListWithSid:_sid SN:_sn success:^(NSArray *commentArray, NSArray *hotList) {
            [weakSelf.comments removeAllObjects];
            [weakSelf.flooredCommentArray removeAllObjects];
            weakSelf.flooredCommentArray = [commentArray convertToFlooredCommentArray];
            if (weakSelf.flooredCommentArray.count) {
                [weakSelf.comments addObject:weakSelf.flooredCommentArray];
            }
            
            [weakSelf.hotFlooredCommentArray removeAllObjects];
            weakSelf.hotFlooredCommentArray = [_flooredCommentArray selectHotFlooredCommentArrayWithHotList:hotList];
            if (weakSelf.hotFlooredCommentArray.count) {
                [weakSelf.comments insertObject:weakSelf.hotFlooredCommentArray atIndex:0];
            }
            
            [weakSelf.commentTableView reloadData];
            
            if (!weakSelf.flooredCommentArray.count) {
                if (self.isExpired) {
                    [WKProgressHUD popMessage:@"评论已关闭" inView:self.view duration:1.5 animated:YES];
                } else {
                    [WKProgressHUD popMessage:@"暂无评论" inView:self.view duration:1.5 animated:YES];
                }
            }
            
            [weakSelf.refreshHeader endRefreshing];
        } failure:^(NSError *error) {
            NSLog(@"%@",error);
            [WKProgressHUD popMessage:error.userInfo[@"NSLocalizedDescription"] inView:self.view duration:1.5 animated:YES];
            [weakSelf.refreshHeader endRefreshing];
            
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
            if ([data[@"state"] isEqualToString:@"success"]) {
                NSArray *cmList = [commentList mj_objectArrayWithKeyValuesArray:data[@"result"][@"cmntlist"]];
                NSArray *hotList = [commentList mj_objectArrayWithKeyValuesArray:data[@"result"][@"hotlist"]];
                
                NSMutableArray *commentArray = [NSMutableArray array];
                //NSMutableArray *hotNews = [NSMutableArray array];
                
                int index = 0;
                int total = (int)[data[@"result"][@"cmntlist"] count];
                for (commentList *temp in cmList) {
                    commentModel *comment = [commentModel mj_objectWithKeyValues:data[@"result"][@"cmntstore"][temp.tid]];
                    comment.floor = [NSString stringWithFormat:@"%d楼",total-index];
                    index++;
                    [commentArray addObject:comment];
                }
                if (success) {
                    success(commentArray, hotList);
                }

            } else {
                if (failure) {
                    failure(data[@"error"]);
                }
            }
            
        } else {
            if (failure) {
                failure(error);
            }
        }
        
    }];
    
}

- (void)postComment
{
    commentPostViewController *vc = [[commentPostViewController alloc]initWithNibName:@"commentPostViewController" bundle:nil];
    vc.sid = self.sid;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - replyActionDelegate

- (void)showReplyActionsWithTid:(NSString *)tid
{
    self.cellTid = tid;
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"回复", @"支持", @"反对", nil];
    [actionSheet showInView:self.commentTableView];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == [actionSheet cancelButtonIndex]) {
        return;
    }
    if (buttonIndex == 0) {
        commentPostViewController *vc = [[commentPostViewController alloc]initWithNibName:@"commentPostViewController" bundle:nil];
        vc.sid = self.sid;
        vc.tid = self.cellTid;
        [self.navigationController pushViewController:vc animated:YES];
        
    } else if (buttonIndex == 1){
        [[HTTPRequester sharedHTTPRequester]voteCommentWithSid:self.sid andTid:self.cellTid actionType:@"support" completion:^(id responseObject, NSError *error) {
            if (error) {
                [JDStatusBarNotification showWithStatus:@"操作失败" dismissAfter:2];
            } else {
                NSDictionary *result = responseObject;
                if ([result[@"state"] isEqualToString:@"success"]) {
                    [WKProgressHUD popMessage:@"操作成功,请稍后刷新" inView:self.view duration:1.5 animated:YES];
                    //[JDStatusBarNotification showWithStatus:@"操作成功,请稍后刷新" dismissAfter:2];
                } else {
                    [WKProgressHUD popMessage:@"操作失败" inView:self.view duration:1.5 animated:YES];
                    //[JDStatusBarNotification showWithStatus:@"操作失败" dismissAfter:2];
                }
            }
        }];
    } else {
        [[HTTPRequester sharedHTTPRequester]voteCommentWithSid:self.sid andTid:self.cellTid actionType:@"against" completion:^(id responseObject, NSError *error) {
            if (error) {
                [JDStatusBarNotification showWithStatus:@"操作失败" dismissAfter:2];
            } else {
                NSDictionary *result = responseObject;
                if ([result[@"state"] isEqualToString:@"success"]) {
                    [WKProgressHUD popMessage:@"操作成功,请稍后刷新" inView:self.view duration:1.5 animated:YES];
                    //[JDStatusBarNotification showWithStatus:@"操作成功,请稍后刷新" dismissAfter:2];
                } else {
                    [WKProgressHUD popMessage:@"操作失败" inView:self.view duration:1.5 animated:YES];
                    //[JDStatusBarNotification showWithStatus:@"操作失败" dismissAfter:2];
                }
            }
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.comments.count;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.comments[section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    commentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"newCell" forIndexPath:indexPath];
    cell.delegate = self;
    
    cell.flooredCommentItem = self.comments[indexPath.section][indexPath.row];
    //NSLog(@"%ld", (long)indexPath.row);
    // Configure the cell...return
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    flooredCommentModel *flooredCommentItem = self.comments[indexPath.section][indexPath.row];
    
    
    LayoutCommentView *commentView = [[LayoutCommentView alloc]initWithModel:flooredCommentItem];
    
  
//    return [_commentTableView fd_heightForCellWithIdentifier:@"newCell" cacheByIndexPath:indexPath configuration:^(id cell) {
//        [cell setFlooredCommentItem:flooredCommentItem];
//    }];
    
    return commentView.frame.size.height + 80;
    
    
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
//    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, 300.0, 44.0)];
//    
//    UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//    headerLabel.backgroundColor = [UIColor clearColor];
//    headerLabel.opaque = NO;
//    
//    headerLabel.highlightedTextColor = [UIColor whiteColor];
//    headerLabel.font = [UIFont systemFontOfSize:13];
//    headerLabel.frame = CGRectMake(10.0, 0.0, 300.0, 25.0);
    DYSectionHeader *sectionHeader = [[DYSectionHeader alloc]initWithFrame:CGRectMake(0.0, 0.0, ScreenWidth, 25.0)];
    
    if ([self.hotFlooredCommentArray count]) {
        if (section == 0) {
            sectionHeader.text =  @"  热门评论";
            sectionHeader.headerColor = [UIColor redColor];
        }else {
            sectionHeader.text = @"  全部评论";
            sectionHeader.headerColor = [UIColor brownColor];
        }
    }else if ([self.flooredCommentArray count]){
        sectionHeader.text = @"  全部评论";
        sectionHeader.headerColor = [UIColor brownColor];

    }
    
    
    return sectionHeader;
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
