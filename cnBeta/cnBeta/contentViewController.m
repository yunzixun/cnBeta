//
//  contentViewController.m
//  cnBeta
//
//  Created by hudy on 16/6/22.
//  Copyright © 2016年 hudy. All rights reserved.
//

#define SCREEN_WIDTH                    ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT                   ([UIScreen mainScreen].bounds.size.height)

#import "contentViewController.h"
#import "commentViewController.h"
#import "CBHTTPRequester.h"
#import "NSDate+gyh.h"
#import "FileCache.h"
#import "NewsContentModel.h"
#import "MJExtension.h"
#import "ObjectiveGumbo.h"
#import "DataBase.h"
#import "collectionModel.h"
#import "CBArticle.h"
#import "CBStarredCache.h"
#import "CBObjectCache.h"
#import "CBCachedURLResponse.h"
//#import "UMSocial.h"
#import "UMSocialUIManager.h"
#import "NewsNavigationViewController.h"
#import "JSBadgeView.h"
#import "WKProgressHUD.h"
#import "IDMPhotoBrowser.h"
//#import <ShareSDK/ShareSDK.h>
//#import <ShareSDKUI/ShareSDK+SSUI.h>


@interface contentViewController ()<UIWebViewDelegate>

@property (nonatomic, copy)NSString *contentHTMLString;
@property (nonatomic, copy)NSString *contentURL;
@property (nonatomic, strong)NewsContentModel *newsContent;
@property (nonatomic, strong)DataBase *collection;
@property (nonatomic, strong)collectionModel *news;
@property (nonatomic, strong)CBArticle *article;
@property (nonatomic, strong)CBHTTPRequester *articleRequester;
@property (nonatomic, strong)CBHTTPRequester *commentNumberRequester;

@property (weak, nonatomic) IBOutlet UIButton *starButton;

@property (weak, nonatomic) IBOutlet UIButton *commentNum;

@property (weak, nonatomic) JSBadgeView *badgeView;

@property (nonatomic, assign) BOOL isExpired;

@end

@implementation contentViewController

- (void)dealloc
{
    [self.articleRequester cancel];
    [self.commentNumberRequester cancel];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
    _collection = [DataBase sharedDataBase];
    //[self.starButton setSelected: [self.article isStarred]];
    _contentWebView.delegate = self;
    
    //评论数量badge
    JSBadgeView *badgeView = [[JSBadgeView alloc]initWithParentView:self.commentNum alignment:JSBadgeViewAlignmentTopRight];
    self.badgeView = badgeView;
    self.badgeView.badgePositionAdjustment = CGPointMake(-14, 15);
    [self.badgeView setBadgeTextFont:[UIFont systemFontOfSize:10]];

    _spinner.center = CGPointMake(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2 );
    [_spinner startAnimating];
    [self setupWebView];
    
    //右滑手势
//    self.panLeft = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanLeft:)];
//    [self.contentWebView addGestureRecognizer:self.panLeft];
}

- (collectionModel *)news
{
    if (!_news) {
        _news = [[collectionModel alloc]init];
        _news.sid = _newsId;
        _news.title = _article.title;
        _news.thumb = _thumb;
    }
    return _news;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.starButton setSelected: [self.article isStarred]];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)setupWebView
{
    CBHTTPRequester *requester = [CBHTTPRequester requester];
    self.articleRequester = requester;
    [requester fetchArticleWithSid:self.newsId completion:^(id responseObject, NSError *error) {
        if (!error) {
            self.article = (CBArticle *)responseObject;
            [self.starButton setSelected: [self.article isStarred]];
            NSRange range = [_thumb rangeOfString:@"-hm_"];
            if (range.length > 0) {
                self.article.thumb = [_thumb substringToIndex:range.location];
            } else {
                self.article.thumb = _thumb;
            }
            self.article.author = self.author;
            NSString *html = [self.article toHTML];
            NSURL* baseURL = [[NSBundle mainBundle] bundleURL];
            [self.contentWebView loadHTMLString:html baseURL:baseURL];
            //[self webViewDidFinishLoad:_contentWebView];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_spinner stopAnimating];
            });
        }
        
    }];
    
    
    //更新评论数目
    CBHTTPRequester *commentNumberRequester = [CBHTTPRequester requester];
    self.commentNumberRequester = commentNumberRequester;
    [commentNumberRequester requestWithURLType:@"content" andId:self.newsId completion:^(id data, NSError *error) {
        if (!error) {
            
            NSArray *dataDic = @[(NSDictionary *)data[@"result"]];
            _newsContent = [NewsContentModel mj_objectArrayWithKeyValuesArray:dataDic][0];
            
            //新闻发布是否已超过24小时
            NSDateFormatter *fmt = [[NSDateFormatter alloc]init];
            fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            NSDate *pubDate = [fmt dateFromString:_newsContent.time];
            //NSLog(@"%@", pubDate);
            NSDateComponents *timeDelta = [pubDate deltaWithNow];
            //NSLog(@"%@", timeDelta);
            if (timeDelta.hour > 72) {
                self.isExpired = YES;
            }
            //评论数目
            self.badgeView.badgeText = [NSString stringWithFormat:@"%@", _newsContent.comments];
        }
    }];

}



//webview中图片自适应宽度
//- (void)webViewDidFinishLoad:(UIWebView *)webView {
//    NSString *js = @"function imgAutoFit() { \
//    var imgs = document.getElementsByTagName('img'); \
//    for (var i = 0; i < imgs.length; ++i) {\
//    var img = imgs[i];  \
//    img.style.maxWidth = %f;  \
//    } \
//    }";
//    js = [NSString stringWithFormat:js, [UIScreen mainScreen].bounds.size.width - 20];
//    
//    [webView stringByEvaluatingJavaScriptFromString:js];
//    [webView stringByEvaluatingJavaScriptFromString:@"imgAutoFit()"];
//    
//    
//}

- (UIImage *)queryCachedImageForKey:(NSString *)key
{
    CBCachedURLResponse *cachedRespone = [[CBObjectCache sharedCache] objectForKey:key];
    if (cachedRespone && [cachedRespone isKindOfClass:[CBCachedURLResponse class]]) {
        if (cachedRespone.responseData) {
            return [UIImage imageWithData:cachedRespone.responseData];
        }
    }
    return nil;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType==UIWebViewNavigationTypeLinkClicked) {
        if ([request.URL.scheme isEqualToString:@"cnbeta"]) {
            if (![self queryCachedImageForKey:request.URL.query]) {
                return NO;
            }
            
            IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotoURLs:self.article.imageUrls];
            NSUInteger index = [self.article.imageUrls indexOfObject:request.URL.query];
            [browser setInitialPageIndex:index];
            [self presentViewController:browser animated:YES completion:nil];
            
            browser.displayActionButton = YES;
            browser.displayArrowButton = YES;
            browser.displayCounterLabel = YES;
            return NO;
        }
    }
    return YES;
}


#pragma mark - Actions

//- (void)handlePanLeft:(UIPanGestureRecognizer *)sender
//{
//    UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)sender;
//    
//    CGPoint point = [pan translationInView:self.view];
//    if (point.x < 0) {
//        [self.navigationController pushViewController:[[commentViewController alloc]initWithSid:_newsId andSN:_sn] animated:YES];
//
//    }
//}

- (IBAction)showComments:(id)sender
{
    [self.navigationController pushViewController:[[commentViewController alloc]initWithArticle:self.article Type:self.isExpired] animated:YES];
}

- (IBAction)collectNews:(id)sender
{
    _starButton.selected = !_starButton.selected;
    
    if (self.starButton.selected) {
        self.news.time = [NSDate currentTime];
        [_collection addNews:_news];
        [[CBStarredCache sharedCache]starArticleWithId:self.article.newsId];
    }else {
        [_collection deleteCellOfSid:_newsId];
        [[CBStarredCache sharedCache]unstarArticleWithId:self.article.newsId];
    }
}

//- (IBAction)refreshWebView:(UIButton *)sender {
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    [defaults setBool:YES forKey:@"Refresh"];
//    //[defaults synchronize];
//    [WKProgressHUD showInView:self.view withText:@"" animated:YES];
//    [self startDownloadContent:self.newsId];
//    
//}

- (IBAction)goBack:(UIButton *)sender {
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
}

- (IBAction)shareNews:(UIButton *)sender {
    __weak typeof(self) weakSelf = self;
    //显示分享面板
    [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMShareMenuSelectionView *shareSelectionView, UMSocialPlatformType platformType) {
        // 根据platformType调用相关平台进行分享
        [weakSelf shareTextToPlatformType:platformType];
        
    }];
 
}

- (void)shareTextToPlatformType:(UMSocialPlatformType)platformType
{
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    //创建网页内容对象
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:_article.title descr:_article.summary thumImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_article.thumb]]]];
    //设置网页地址
    shareObject.webpageUrl =[NSString stringWithFormat:@"http://www.cnbeta.com/articles/%@.htm",_article.newsId];
    
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
        if (error) {
            NSLog(@"************Share fail with error %@*********",error);
        }else{
            NSLog(@"response data is %@",data);
        }
    }];
}
#pragma mark - Navigation
/**
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
