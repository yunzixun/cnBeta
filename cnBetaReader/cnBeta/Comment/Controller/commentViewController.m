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
#import "commentPostViewController.h"

#import "commentList.h"
#import "commentModel.h"
#import "collectionModel.h"
#import "flooredCommentModel.h"
#import "commentCell.h"
#import "LayoutCommentView.h"
#import "CBSectionHeader.h"
#import "CBCmtListHeaderView.h"
#import "CBCommentToolbar.h"

#import "MJExtension.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "NSArray+transform.h"
#import "CBHTTPRequester.h"
#import "CBDataBase.h"
#import "CBStarredCache.h"
#import "CBAppSettings.h"
#import "DYKeyedHeightCache.h"
#import "JDStatusBarNotification.h"
#import "WKProgressHUD.h"
#import "NSDate+gyh.h"
#import "MJRefresh.h"
#import "CBAppSettings.h"
#import "UIColor+CBColor.h"

static CGFloat kStatusBarHeight = 20.0f;
static CGFloat kToolbarHeight = 49.0f;

@interface commentViewController ()<UIScrollViewDelegate, UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,replyActionDelegate>
@property (nonatomic, strong)CBCmtListHeaderView *headerView;
@property (weak, nonatomic) IBOutlet UITableView *commentTableView;

@property (weak, nonatomic) IBOutlet UIView *statusBarBackground;
@property (weak, nonatomic) IBOutlet CBCommentToolbar *toolbar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *statusBarTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarBottomConstraint;

@property (nonatomic, strong)NSMutableArray *flooredCommentArray;
@property (nonatomic, strong)NSMutableArray *hotFlooredCommentArray;
@property (nonatomic, strong)NSMutableArray *comments;

@property (nonatomic, strong)CBHTTPRequester *commentsRequester;
@property (nonatomic, strong)DYKeyedHeightCache *heightCache;
@property (nonatomic, assign)CGPoint lastContentOffset;
@end

@implementation commentViewController

- (void)dealloc
{
    [self.commentsRequester cancel];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

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

- (CBCmtListHeaderView *)headerView
{
    if (!_headerView) {
        _headerView = [[CBCmtListHeaderView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 64 - kStatusBarHeight)];
        _headerView.title = self.article.title;
        _headerView.titleBackGroundColor = [UIColor cb_cmtListTitleBackgroundColor];
    }
    return _headerView;
}

//- (CBCommentToolbar *)toolbar
//{
//    if (!_toolbar) {
//        _toolbar = [[CBCommentToolbar alloc] initWithFrame:CGRectMake(0, ScreenHeight - kToolbarHeight, ScreenWidth, kToolbarHeight)];
//    }return _toolbar;
//    
//}

- (id)initWithArticle:(CBArticle *)article type: (BOOL)isExpired
{
    if (self = [super init]) {
        self.article = article;
        self.isExpired = isExpired;
    }
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.heightCache = [[DYKeyedHeightCache alloc] init];
    self.statusBarBackground.backgroundColor = [UIColor cb_backgroundColor];
    self.commentTableView.backgroundColor = [UIColor cb_backgroundColor];
    self.commentTableView.separatorColor = [UIColor cb_newsTableViewSeparatorColor];
    
    _commentTableView.tableHeaderView = self.headerView;
    UIEdgeInsets insets = [self.commentTableView contentInset];
    insets.top = kStatusBarHeight;
    insets.bottom = kToolbarHeight;
    _commentTableView.contentInset = insets;
    _commentTableView.scrollIndicatorInsets = insets;
    if ([_commentTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_commentTableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    if ([_commentTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_commentTableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
    _commentTableView.delegate = self;
    _commentTableView.dataSource = self;
    _commentTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [_commentTableView registerNib:[UINib nibWithNibName:@"commentCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"newCell"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoStar) name:@"autoStar" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged) name:CBAppSettingThemeChangedNotification object:nil];
    
    [self.view addSubview:self.toolbar];
    [_toolbar.backBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [_toolbar.commentBtn addTarget:self action:@selector(postComment) forControlEvents:UIControlEventTouchUpInside];
    [_toolbar.refreshBtn addTarget:self action:@selector(refresh) forControlEvents:UIControlEventTouchUpInside];
    [_toolbar.toBottomBtn addTarget:self action:@selector(toBottom) forControlEvents:UIControlEventTouchUpInside];

    [self setupRefreshView];
    
    //[LSCommentTool loadCommentListWithSid:self.sid pageNum:[NSString stringWithFormat:@"%tu",self.pageNum] SN:self.sn success:^(NSArray *commentArray) {

}

- (void)themeChanged
{
    self.statusBarBackground.backgroundColor = [UIColor cb_backgroundColor];
    self.commentTableView.backgroundColor = [UIColor cb_backgroundColor];
    self.commentTableView.separatorColor = [UIColor cb_newsTableViewSeparatorColor];
    self.headerView.titleBackGroundColor = [UIColor cb_cmtListTitleBackgroundColor];
    [self.commentTableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([[UIApplication sharedApplication] isStatusBarHidden]) {
        self.statusBarTopConstraint.constant = -kStatusBarHeight;
    } else {
        self.statusBarTopConstraint.constant = 0;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];

}

- (void)setupRefreshView
{
    self.commentTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefresh)];
    self.commentTableView.mj_header.automaticallyChangeAlpha = YES;
    [self.commentTableView.mj_header beginRefreshing];
}

- (void)headerRefresh
{
    [self loadCommentListWithArticle:self.article success:^(NSArray *commentArray, NSArray *hotList) {
        [self.comments removeAllObjects];
        [self.flooredCommentArray removeAllObjects];
        self.flooredCommentArray = [commentArray convertToFlooredCommentArray];
        if (self.flooredCommentArray.count) {
            [self.comments addObject:self.flooredCommentArray];
        }
        
        [self.hotFlooredCommentArray removeAllObjects];
        self.hotFlooredCommentArray = [_flooredCommentArray selectHotFlooredCommentArrayWithHotList:hotList];
        if (self.hotFlooredCommentArray.count) {
            [self.comments insertObject:self.hotFlooredCommentArray atIndex:0];
        }
        [self.commentTableView.mj_header endRefreshing];

        [self.commentTableView reloadData];
        
        if (!self.flooredCommentArray.count) {
            if (self.article.commentCount.intValue > 0 && self.isExpired) {
                [WKProgressHUD popMessage:@"评论已关闭" inView:self.view duration:1.5 animated:YES];
            } else {
                [WKProgressHUD popMessage:@"暂无评论" inView:self.view duration:1.5 animated:YES];
            }
        }
    } failure:^(NSError *error, NSString *type) {
        NSLog(@"%@",error);
        [self.commentTableView.mj_header endRefreshing];

        if ([type isEqualToString:@"string"]) {
            [WKProgressHUD popMessage:(NSString *)error inView:self.view duration:1.5 animated:YES];
        } else {
            [WKProgressHUD popMessage:error.userInfo[@"NSLocalizedDescription"] inView:self.view duration:1.5 animated:YES];
        }
    }];

}



- (void)loadCommentListWithArticle:(CBArticle *)article success:(void (^)(NSArray *, NSArray *))success failure:(void(^)(NSError * error, NSString *type))failure{
    NSString *url = [NSString stringWithFormat:@"http://www.cnbeta.com/cmt?op=1,%@,%@", article.newsId, article.sn];
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [headers setObject:@"XMLHttpRequest" forKey:@"X-Requested-With"];
    [headers setObject:@"http://www.cnbeta.com/" forKey:@"Referer"];
    
    CBHTTPRequester *commentsRequester = [CBHTTPRequester requester];
    self.commentsRequester = commentsRequester;
    [commentsRequester requestWithURL:url andHeaders:headers completion:^(id data, NSError *error) {
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
                    failure(data[@"error"], @"string");
                }
            }
            
        } else {
            if (failure) {
                failure(error, @"struct");
            }
        }
        
    }];
    
}

- (void)autoStar
{
    if ([[CBAppSettings sharedSettings] autoCollectionEnabled]) {
        collectionModel *news = [[collectionModel alloc] init];
        news.sid = self.article.newsId;
        news.title = self.article.title;
        news.thumb = self.article.thumb;
        news.time = [NSDate currentTime];
        [[CBDataBase sharedDataBase] starArticle:news];
        [[CBStarredCache sharedCache] starArticleWithId:self.article.newsId];
    }
}
     
- (void)goBack
{
    [self.stackController popViewControllerAnimated:YES];
}

- (void)refresh
{
    [self.commentTableView.mj_header beginRefreshing];
}

- (void)toBottom
{
    if (self.commentTableView.contentSize.height > ScreenHeight) {
        [self.commentTableView setContentOffset:CGPointMake(0, _commentTableView.contentSize.height - _commentTableView.frame.size.height) animated:YES];
    }
}

- (void)postComment
{
    commentPostViewController *vc = (commentPostViewController *)self.nextViewController;
    [self.stackController pushViewController:vc animated:YES];
}

#pragma mark - replyActionDelegate

- (void)reply:(CBCellButton *)button
{
    commentPostViewController *vc = [[commentPostViewController alloc]initWithNibName:@"commentPostViewController" bundle:nil];
    vc.sid = self.article.newsId;
    commentModel *comment = button.commentInfo;
    vc.tid = comment.tid;
    [self.stackController pushViewController:vc animated:YES];
}
- (void)support:(CBCellButton *)button
{
    commentModel *comment = button.commentInfo;
    if (comment.supported) {
        return;
    }
    
    comment.score = [@([comment.score intValue]+1) stringValue];
    comment.supported = YES;
    [self.commentTableView reloadRowsAtIndexPaths:@[button.indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [[CBHTTPRequester requester] voteCommentWithSid:self.article.newsId andTid:comment.tid actionType:@"support" completion:^(id responseObject, NSError *error) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        if (error) {
            [JDStatusBarNotification showWithStatus:@"操作失败" dismissAfter:2 styleName:JDStatusBarStyleError];
        } else {
             NSDictionary *result = responseObject;
            if ([result[@"state"] isEqualToString:@"success"]) {
                //[WKProgressHUD popMessage:@"操作成功" inView:self.view duration:1.5 animated:YES];
                [JDStatusBarNotification showWithStatus:@"操作成功" dismissAfter:1.5 styleName:JDStatusBarStyleSuccess];
            } else {
                //[WKProgressHUD popMessage:@"操作失败" inView:self.view duration:1.5 animated:YES];
                [JDStatusBarNotification showWithStatus:@"操作失败" dismissAfter:1.5 styleName:JDStatusBarStyleError];
            }
        }
    }];

}
- (void)oppose:(CBCellButton *)button
{
    commentModel *comment = button.commentInfo;
    if (comment.opposed) {
        return;
    }
    
    comment.reason = [@([comment.reason intValue]+1) stringValue];
    comment.opposed = YES;
    [self.commentTableView reloadRowsAtIndexPaths:@[button.indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [[CBHTTPRequester requester] voteCommentWithSid:self.article.newsId andTid:comment.tid actionType:@"against" completion:^(id responseObject, NSError *error) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        if (error) {
            [JDStatusBarNotification showWithStatus:@"操作失败" dismissAfter:2 styleName:JDStatusBarStyleError];
        } else {
            NSDictionary *result = responseObject;
            if ([result[@"state"] isEqualToString:@"success"]) {
                //[WKProgressHUD popMessage:@"操作成功" inView:self.view duration:1.5 animated:YES];
                [JDStatusBarNotification showWithStatus:@"操作成功" dismissAfter:1.5 styleName:JDStatusBarStyleSuccess];
            } else {
                //[WKProgressHUD popMessage:@"操作失败" inView:self.view duration:1.5 animated:YES];
                [JDStatusBarNotification showWithStatus:@"操作失败" dismissAfter:1.5 styleName:JDStatusBarStyleError];
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
    return self.comments.count;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.comments[section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    commentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"newCell" forIndexPath:indexPath];
    //commentCell *cell = [commentCell cellWithTableView:tableView Identifier: @"newCell"];
    cell.delegate = self;
    
    cell.indexPath = indexPath;
    cell.flooredCommentItem = self.comments[indexPath.section][indexPath.row];
    if (self.comments.count ==2 && indexPath.section == 0) {
        cell.floor.textColor = [UIColor redColor];
    } else {
        cell.floor.textColor = [UIColor lightGrayColor];
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    flooredCommentModel *flooredCommentItem = self.comments[indexPath.section][indexPath.row];
    
    
    if ([self.comments[indexPath.section] count] == 100) {
        LayoutCommentView *commentView = [[LayoutCommentView alloc]initWithModel:flooredCommentItem];
        return commentView.frame.size.height + 80;
    }
    CGFloat height = [self.heightCache heightForCellWithModel:flooredCommentItem cachedByKey:[self.article.newsId stringByAppendingString:flooredCommentItem.tid] configuration:^CGFloat(id model) {
        LayoutCommentView *commentView = [[LayoutCommentView alloc]initWithModel:flooredCommentItem];
        return commentView.frame.size.height + 80;
    }];
  
 //   return [_commentTableView fd_heightForCellWithIdentifier:@"newCell" cacheByIndexPath:indexPath configuration:^(id cell) {
//        [cell setFlooredCommentItem:flooredCommentItem];
//    }];
    
    return height;
    
    
}



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
    CBSectionHeader *sectionHeader = [[CBSectionHeader alloc]initWithFrame:CGRectMake(0.0, 0.0, ScreenWidth, 25.0)];
    sectionHeader.section = section;
    sectionHeader.tableview = tableView;
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

#pragma mark - ScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (![CBAppSettings sharedSettings].fullScreenEnabled) {
        return;
    } else {
        CGFloat distance = scrollView.contentOffset.y - self.lastContentOffset.y;
        if (distance > 0 && scrollView.contentOffset.y > 0) {
            //pull up
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
            
            [UIView animateWithDuration:0.3 animations:^{
                self.statusBarTopConstraint.constant = -kStatusBarHeight;
                self.toolbarBottomConstraint.constant = -kToolbarHeight;

//                UIEdgeInsets insets = scrollView.scrollIndicatorInsets;
//                insets.top = 0;
//                insets.bottom = 0;
//                scrollView.scrollIndicatorInsets = insets;
                //[self.view layoutIfNeeded];
            }];
        } else {
            //pull down
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
            
            [UIView animateWithDuration:0.3 animations:^{
                self.statusBarTopConstraint.constant = 0;
                self.toolbarBottomConstraint.constant = 0;
                
//                UIEdgeInsets insets = scrollView.scrollIndicatorInsets;
//                insets.top = kStatusBarHeight;
//                insets.bottom = kToolbarHeight;
//                scrollView.scrollIndicatorInsets = insets;
                //[self.view layoutIfNeeded];
            }];
        }
    }
    
    self.lastContentOffset = scrollView.contentOffset;
}

#pragma mark - CWStack

- (UIViewController *)nextViewController
{
    commentPostViewController *commentPostvc = [[commentPostViewController alloc]initWithNibName:@"commentPostViewController" bundle:nil];
    commentPostvc.sid = self.article.newsId;
    return commentPostvc;

}



@end
