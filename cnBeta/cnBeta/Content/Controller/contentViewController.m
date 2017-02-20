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
#import "NewsContentModel.h"
#import "MJExtension.h"
#import "ObjectiveGumbo.h"
#import "CBDataBase.h"
#import "collectionModel.h"
#import "CBArticle.h"
#import "CBStarredCache.h"
#import "CBObjectCache.h"
#import "CBCachedURLResponse.h"
//#import "UMSocial.h"
#import "UMSocialUIManager.h"
#import "JSBadgeView.h"
#import "WKProgressHUD.h"
#import "IDMPhotoBrowser.h"
#import "CBAppSettings.h"
#import "MBProgressHUD+NJ.h"

static CGFloat kStatusBarHeight = 20.0f;
static CGFloat kToolbarHeight = 49.0f;

@interface contentViewController ()<UIWebViewDelegate, UIScrollViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, copy)NSString *contentHTMLString;
@property (nonatomic, copy)NSString *contentURL;
@property (nonatomic, strong)NewsContentModel *newsContent;
@property (nonatomic, strong)collectionModel *news;
@property (nonatomic, strong)CBArticle *article;
@property (nonatomic, strong)CBHTTPRequester *articleRequester;
@property (nonatomic, strong)CBHTTPRequester *commentNumberRequester;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *starButton;
@property (weak, nonatomic) IBOutlet UIView *statusBarBackground;
@property (weak, nonatomic) IBOutlet UIButton *commentNum;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *statusBarTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarBottomConstraint;

@property (nonatomic, strong) UILongPressGestureRecognizer *shareLongPressGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *refetchTapGestureRecognizer;
@property (weak, nonatomic) JSBadgeView *badgeView;
@property (nonatomic) BOOL isExpired;
@property (nonatomic, assign)CGPoint lastContentOffset;

@end

@implementation contentViewController

- (void)dealloc
{
    [self.articleRequester cancel];
    [self.commentNumberRequester cancel];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.statusBarBackground.backgroundColor = [UIColor cb_backgroundColor];
    //[self.starButton setSelected: [self.article isStarred]];
    UIEdgeInsets insets = [[self.contentWebView scrollView] contentInset];
    insets.top = kStatusBarHeight;
    insets.bottom = kToolbarHeight;
    _contentWebView.scrollView.contentInset = insets;
    _contentWebView.scrollView.scrollIndicatorInsets = insets;
    _contentWebView.delegate = self;
    _contentWebView.scrollView.delegate = self;
    
    self.shareLongPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(determineIfSaveArticleToImage)];
    self.shareLongPressGestureRecognizer.numberOfTouchesRequired = 1;
    self.shareLongPressGestureRecognizer.allowableMovement = 100.0f;
    self.shareLongPressGestureRecognizer.minimumPressDuration = 1.0;
    [self.shareButton addGestureRecognizer:self.shareLongPressGestureRecognizer];
    
    self.refetchTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(refetchArticle)];
    self.refetchTapGestureRecognizer.delegate = self;
    self.refetchTapGestureRecognizer.numberOfTapsRequired = 2;
    [self.contentWebView addGestureRecognizer:self.refetchTapGestureRecognizer];
    
    
    if ([CBAppSettings sharedSettings].isNightMode) {
        [self.commentNum setImage:[UIImage imageNamed:@"toolbar_reply_normal_night_50x50_"] forState:UIControlStateNormal];
        [self.shareButton setImage:[UIImage imageNamed:@"toolbar_share_normal_night_50x50_"] forState:UIControlStateNormal];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged) name:CBAppSettingThemeChangedNotification object:nil];
    
    //评论数量badge
    JSBadgeView *badgeView = [[JSBadgeView alloc]initWithParentView:self.commentNum alignment:JSBadgeViewAlignmentTopRight];
    self.badgeView = badgeView;
    self.badgeView.badgePositionAdjustment = CGPointMake(-15, 15);
    [self.badgeView setBadgeTextFont:[UIFont systemFontOfSize:10]];

    _spinner.center = CGPointMake(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2 );
    [_spinner startAnimating];
    [self setupWebView];
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
    if ([[UIApplication sharedApplication] isStatusBarHidden]) {
        self.statusBarTopConstraint.constant = -kStatusBarHeight;
    } else {
        self.statusBarTopConstraint.constant = 0;
    }
    [self.view layoutIfNeeded];

    //[self.navigationController setNavigationBarHidden:YES animated:YES];
//    self.edgesForExtendedLayout = UIRectEdgeNone;
//    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    
}

- (void)themeChanged
{
    [self.commentNum setImage:[UIImage imageNamed:@"toolbar_reply_normal_night_50x50_"] forState:UIControlStateNormal];
    [self.shareButton setImage:[UIImage imageNamed:@"toolbar_share_normal_night_50x50_"] forState:UIControlStateNormal];
    self.contentWebView.backgroundColor = [UIColor cb_backgroundColor];
    self.statusBarBackground.backgroundColor = [UIColor cb_backgroundColor];
    NSURL* baseURL = [[NSBundle mainBundle] bundleURL];
    CGPoint curOffset = self.contentWebView.scrollView.contentOffset;
    [self.contentWebView loadHTMLString:[self.article toHTML] baseURL:baseURL];
    self.contentWebView.scrollView.contentOffset = curOffset;
}


- (void)setupWebView
{
    CBHTTPRequester *requester = [CBHTTPRequester requester];
    self.articleRequester = requester;
    [requester fetchArticleWithSid:self.newsId useCache:YES completion:^(id responseObject, NSError *error) {
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
            if (timeDelta.hour > 24) {
                self.isExpired = YES;
            }
            self.article.commentCount = @(_newsContent.comments.intValue);
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
        } else {
            NSURL *currentUrl=request.URL;
            [[UIApplication sharedApplication] openURL:currentUrl];
            return NO;
        }
    }
    return YES;
}




#pragma mark - Actions


- (IBAction)showComments:(id)sender
{
    [self.stackController pushViewController:self.nextViewController animated:YES];
}

- (IBAction)collectNews:(id)sender
{
    _starButton.selected = !_starButton.selected;
    
    if (self.starButton.selected) {
        self.news.time = [NSDate currentTime];
        [[CBDataBase sharedDataBase] starArticle:self.news];
        [[CBStarredCache sharedCache]starArticleWithId:self.article.newsId];
    }else {
        [[CBDataBase sharedDataBase] unstarArticle:self.news];
        [[CBStarredCache sharedCache]unstarArticleWithId:self.article.newsId];
    }
}


- (IBAction)goBack:(UIButton *)sender {
    [self.stackController popViewControllerAnimated:YES];
    //[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
}

- (IBAction)shareNews:(UIButton *)sender {
    __weak typeof(self) weakSelf = self;
    //显示分享面板
    [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMShareMenuSelectionView *shareSelectionView, UMSocialPlatformType platformType) {
        //[[UMSocialUIManager defaultManager] configBackgroundColor:[UIColor cb_settingViewBackgroundColor]];
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
    shareObject.webpageUrl =[NSString stringWithFormat:@"http://m.cnbeta.com/view/%@.htm",_article.newsId];
    
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

- (void)refetchArticle
{
    [_spinner startAnimating];
    [self.articleRequester fetchArticleWithSid:self.newsId useCache:NO completion:^(id responseObject, NSError *error) {
        if (!error) {
            self.article = (CBArticle *)responseObject;
            NSRange range = [_thumb rangeOfString:@"-hm_"];
            if (range.length > 0) {
                self.article.thumb = [_thumb substringToIndex:range.location];
            } else {
                self.article.thumb = _thumb;
            }
            self.article.author = self.author;
            CGPoint curOffset = self.contentWebView.scrollView.contentOffset;
            NSString *html = [self.article toHTML];
            NSURL* baseURL = [[NSBundle mainBundle] bundleURL];
            [self.contentWebView loadHTMLString:html baseURL:baseURL];
            self.contentWebView.scrollView.contentOffset = curOffset;
            curOffset = self.contentWebView.scrollView.contentOffset;
            dispatch_async(dispatch_get_main_queue(), ^{
                [_spinner stopAnimating];
            });
        }
    }];
}

- (void)determineIfSaveArticleToImage
{
    [self alertView:@"将文章保存为图片？" message:nil cancel:@"取消"];
}

- (void)alertView:(NSString *)alertString message:(NSString *)msg cancel:(NSString *)action
{
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:alertString message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *leftButton = [UIAlertAction actionWithTitle:action style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *rightButton = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self convertArticleToImage];
    }];
    [alertView addAction:leftButton];
    if ([action isEqual: @"取消"]) {
        [alertView addAction:rightButton];
    }
    [self presentViewController:alertView animated:YES completion:nil];
}

- (void)convertArticleToImage
{
    CGSize boundsSize = self.contentWebView.bounds.size;
    CGFloat boundsWidth = boundsSize.width;
    CGFloat boundsHeight = boundsSize.height;
    
    CGPoint offset = self.contentWebView.scrollView.contentOffset;
    [self.contentWebView.scrollView setContentOffset:CGPointMake(0, 0)];
    NSInteger contentHeight = self.contentWebView.scrollView.contentSize.height;
    NSMutableArray *images = [NSMutableArray array];
    while (contentHeight > 0) {
        UIGraphicsBeginImageContextWithOptions(boundsSize, NO, [UIScreen mainScreen].scale);
        [self.contentWebView.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [images addObject:image];
        
        CGFloat offsetY = self.contentWebView.scrollView.contentOffset.y;
        [self.contentWebView.scrollView setContentOffset:CGPointMake(0, offsetY + boundsHeight)];
        contentHeight -= boundsHeight;
    }
    [self.contentWebView.scrollView setContentOffset:offset];
    
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize imageSize = CGSizeMake(ScreenWidth * scale, self.contentWebView.scrollView.contentSize.height * scale);
    UIGraphicsBeginImageContext(imageSize);
    //UIGraphicsBeginImageContextWithOptions(imageSize, NO, [UIScreen mainScreen].scale);

    [images enumerateObjectsUsingBlock:^(UIImage *image, NSUInteger idx, BOOL *stop) {
        [image drawInRect:CGRectMake(0,
                                     scale * boundsHeight * idx,
                                     scale * boundsWidth,
                                     scale * boundsHeight)];
    }];
    UIImage *fullImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
//    CGRect rect = CGRectMake(0, 0, ScreenWidth, contentHeight);
//    UIImageView * snapshotView = [[UIImageView alloc]initWithFrame:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)];
//    
//    snapshotView.image = [fullImage resizableImageWithCapInsets:UIEdgeInsetsZero];
//    UIImage *image = snapshotView.image;
    UIImageWriteToSavedPhotosAlbum(fullImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image: (UIImage *)image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    NSString *msg = nil;
    if (error) {
        msg = @"保存失败";
        [MBProgressHUD showError:msg];
    } else {
        msg = @"保存成功";
        [MBProgressHUD showSuccess:msg];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    //[otherGestureRecognizer requireGestureRecognizerToFail:gestureRecognizer];
    return YES;
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
            
            self.statusBarTopConstraint.constant = -kStatusBarHeight;
            self.toolbarBottomConstraint.constant = -kToolbarHeight;
            
            [UIView animateWithDuration:0.3 animations:^{
                UIEdgeInsets insets = scrollView.scrollIndicatorInsets;
                insets.top = 0;
                insets.bottom = 0;
                scrollView.scrollIndicatorInsets = insets;
                [self.view layoutIfNeeded];
            }];
        } else {
            //pull down
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
            
            self.statusBarTopConstraint.constant = 0;
            self.toolbarBottomConstraint.constant = 0;
            
            [UIView animateWithDuration:0.3 animations:^{
                UIEdgeInsets insets = scrollView.scrollIndicatorInsets;
                insets.top = kStatusBarHeight;
                insets.bottom = kToolbarHeight;
                scrollView.scrollIndicatorInsets = insets;
                [self.view layoutIfNeeded];
            }];
        }
    }
    
    self.lastContentOffset = scrollView.contentOffset;
}

#pragma mark - CWStack

- (UIViewController *)nextViewController
{
    commentViewController *commentvc = [[commentViewController alloc]initWithNibName:@"commentViewController" bundle:nil];
    commentvc.article = self.article;
    commentvc.isExpired = self.isExpired;
    return commentvc;
}

@end
