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
#import "UIViewController+DownloadNews.h"
#import "NSDate+gyh.h"
#import "FileCache.h"
#import "NewsContentModel.h"
#import "MJExtension.h"
#import "ObjectiveGumbo.h"
#import "DataBase.h"
#import "collectionModel.h"
#import "UMSocial.h"

#import "NewsNavigationViewController.h"
#import "JSBadgeView.h"
#import "WKProgressHUD.h"
//#import <ShareSDK/ShareSDK.h>
//#import <ShareSDKUI/ShareSDK+SSUI.h>


@interface contentViewController ()<UMSocialUIDelegate, UIWebViewDelegate>

@property (nonatomic, copy)NSString *contentHTMLString;
@property (nonatomic, copy)NSString *contentURL;
@property (nonatomic, copy) NSString *sn;
@property (nonatomic, strong)NewsContentModel *newsContent;
@property (nonatomic,strong)DataBase *collection;
@property (nonatomic,strong)collectionModel *news;

@property (weak, nonatomic) IBOutlet UIButton *collect;

@property (nonatomic, strong) UIPanGestureRecognizer *panLeft;

@property (weak, nonatomic) IBOutlet UIButton *commentNum;

@property (weak, nonatomic) JSBadgeView *badgeView;

@property (nonatomic, assign) BOOL isExpired;

@end

@implementation contentViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
    _collection = [DataBase sharedDataBase];
    _news = [[collectionModel alloc]init];
    self.news.sid = _newsId;
    _news.title = _newsTitle;
    _contentWebView.delegate = self;
    
    //评论数量badge
    JSBadgeView *badgeView = [[JSBadgeView alloc]initWithParentView:self.commentNum alignment:JSBadgeViewAlignmentTopRight];
    self.badgeView = badgeView;
    self.badgeView.badgePositionAdjustment = CGPointMake(-6, 5);
    [self.badgeView setBadgeTextFont:[UIFont systemFontOfSize:10]];
    
    //右滑手势
//    self.panLeft = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanLeft:)];
//    [self.contentWebView addGestureRecognizer:self.panLeft];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //self.navigationController.navigationBarHidden = NO;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.hidesBarsOnSwipe = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    _spinner.center = CGPointMake(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2 );
    [_spinner startAnimating];
    
    [self setupWebView];

    
}

- (void)setupWebView
{
    if ([_collection queryWithSid:self.newsId tableType:@"collection"]) {
        _collect.selected = YES;
        [_collect setTitle:@"已收藏" forState:UIControlStateNormal];
        [_collect setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    }
    
    FileCache *fileCache = [FileCache sharedCache];
    _contentHTMLString = [fileCache getHTMLFromFileForKey:self.newsId];
    if (!_contentHTMLString) {
        
        [self startDownloadContent:self.newsId];
        
    } else{
        [_contentWebView loadHTMLString:_contentHTMLString baseURL:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_spinner stopAnimating];
            //[_spinner removeFromSuperview];
            //_spinner.hidden = YES;
        });
        
        //更新评论数目
        [self requestWithURLType:@"content" andId:self.newsId completion:^(id data, NSError *error) {
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
                if (timeDelta.hour >= 24) {
                    self.isExpired = YES;
                }
                //评论数目
                self.badgeView.badgeText = [NSString stringWithFormat:@"%@", _newsContent.comments];
            }
        }];
    }

    [self requestWithURLType:@"SN" andId:_newsId completion:^(id data, NSError *error) {
        if (!error) {
            OGNode *node = [ObjectiveGumbo parseNodeWithData:data];
            NSRange range = [node.text rangeOfString:@"\",SN:\""];
            if (range.location != NSNotFound) {
                _sn = [node.text substringWithRange:NSMakeRange(range.location + range.length, 5)];
                //NSLog(@"%@", _sn);
            }
        }
    }];
    
}

- (void)startDownloadContent:(NSString *)sid
{
    if (sid) {
        
        [self requestWithURLType:@"content" andId:sid completion:^(id data, NSError *error) {
            if (!error) {
                
                [self getHTMLByData:data[@"result"]];
                //NSLog(@"%@",data[@"result"]);
                //缓存到文件系统
                FileCache *fileCache = [FileCache sharedCache];
                [fileCache cacheHTMLToFile:_contentHTMLString forKey:_newsId];
                
            }
            
        }];
    }
}

- (void)getHTMLByData:(id)data
{
    
    NSArray *dataDic = @[(NSDictionary *)data];
    
    _newsContent = [NewsContentModel mj_objectArrayWithKeyValuesArray:dataDic][0];
    //_newsContent.source = @"";
    self.badgeView.badgeText = [NSString stringWithFormat:@"%@", _newsContent.comments];
    
    NSMutableString *cmt = [NSMutableString stringWithFormat:@"%@条评论", _newsContent.comments];
    
    //新闻发布是否已超过24小时
    NSDateFormatter *fmt = [[NSDateFormatter alloc]init];
    fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *pubDate = [fmt dateFromString:_newsContent.time];
    //NSLog(@"%@", pubDate);
    NSDateComponents *timeDelta = [pubDate deltaWithNow];
    //NSLog(@"%@", timeDelta);
    if (timeDelta.hour >= 24) {
        [cmt appendString:@"(评论已关闭)"];
    }
    
    NSMutableString *allTitleStr =[NSMutableString stringWithString:@"<style type='text/css'> p.thicker{font-weight: 500}p.light{font-weight: 0}p{font-size: 108%}h2 {font-size: 120%}h3 {font-size: 80%}</style> <h2 class = 'thicker'>title</h2><h3>hehe      lala      gaga</h3>"];
    
    [allTitleStr replaceOccurrencesOfString:@"title" withString:_newsContent.title options:NSCaseInsensitiveSearch range:[allTitleStr rangeOfString:@"title"]];
    [allTitleStr replaceOccurrencesOfString:@"hehe" withString:_newsContent.source options:NSCaseInsensitiveSearch range:[allTitleStr rangeOfString:@"hehe"]];
    [allTitleStr replaceOccurrencesOfString:@"lala" withString:_newsContent.time options:NSCaseInsensitiveSearch range:[allTitleStr rangeOfString:@"lala"]];
    [allTitleStr replaceOccurrencesOfString:@"gaga" withString:cmt options:NSCaseInsensitiveSearch range:[allTitleStr rangeOfString:@"gaga"]];
    
    NSMutableString *head = (NSMutableString *)@"<head><style>img{width:360px !important;}</style></head>";
    _contentHTMLString = [[[head stringByAppendingString:allTitleStr] stringByAppendingString:_newsContent.hometext] stringByAppendingString:_newsContent.bodytext];
    
    NSString *origin = [NSString stringWithFormat:@"<div style=\"text-align:center;\"><a href=\"http://www.cnbeta.com/articles/%@.htm\" target=\"_blank\">查看原文</a></div>", self.newsId];
    _contentHTMLString = [_contentHTMLString stringByAppendingString:origin];
    
    [_contentWebView loadHTMLString:_contentHTMLString baseURL:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_spinner stopAnimating];
        //[_spinner removeFromSuperview];
        //_spinner.hidden = YES;
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Refresh"]) {
            [WKProgressHUD dismissInView:self.view animated:YES];
            [WKProgressHUD popMessage:@"刷新成功" inView:self.view duration:1.5 animated:YES];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"Refresh"];

        }
    });
    
    
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType==UIWebViewNavigationTypeLinkClicked) {
        NSURL *currentUrl=request.URL;
        [[UIApplication sharedApplication] openURL:currentUrl];
        return NO;
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
    [self.navigationController pushViewController:[[commentViewController alloc]initWithSid:_newsId andSN:_sn Type:self.isExpired] animated:YES];
}

- (IBAction)collectNews:(id)sender
{
    _collect.selected = !_collect.selected;
    
    if (self.collect.selected) {
        [_collect setTitle:@"已收藏" forState:UIControlStateNormal];
        [_collect setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
        _news.time = [NSDate currentTime];
        [_collection addNews:_news];
    }else {
        [_collect setTitle:@"收藏" forState:UIControlStateNormal];
        [_collect setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        [_collection deleteCellOfSid:_newsId];
    }
}

- (IBAction)refreshWebView:(UIButton *)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"Refresh"];
    //[defaults synchronize];
    [WKProgressHUD showInView:self.view withText:@"" animated:YES];
    [self startDownloadContent:self.newsId];
    
}

- (IBAction)goBack:(UIButton *)sender {
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
}

- (IBAction)shareNews:(UIButton *)sender {
    //[[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeImage url:_thumb];
    [UMSocialData defaultData].extConfig.title = _newsTitle;
    [UMSocialData defaultData].extConfig.qqData.url = [NSString stringWithFormat:@"http://www.cnbeta.com/articles/%@.htm",_newsId];
    [UMSocialData defaultData].extConfig.qzoneData.url = [NSString stringWithFormat:@"http://www.cnbeta.com/articles/%@.htm",_newsId];
    [UMSocialData defaultData].extConfig.wechatSessionData.url = [NSString stringWithFormat:@"http://www.cnbeta.com/articles/%@.htm",_newsId];
    //[UMSocialData defaultData].extConfig.wechatSessionData.title = _newsTitle;
    [UMSocialData defaultData].extConfig.wechatTimelineData.url = [NSString stringWithFormat:@"http://www.cnbeta.com/articles/%@.htm",_newsId];
    //[UMSocialData defaultData].extConfig.wechatTimelineData.title = _newsTitle;
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:@"579b1ed4e0f55ab08c000e90"
                                      shareText:[NSString stringWithFormat:@"http://www.cnbeta.com/articles/%@.htm",_newsId]
                                     shareImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_thumb]]]
                                shareToSnsNames:@[UMShareToWechatSession,UMShareToWechatTimeline,UMShareToQQ,UMShareToQzone]
                                       delegate:self];
}

-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        //得到分享到的平台名
        NSLog(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
    }
}

//- (IBAction)shareNews:(id)sender
//{
//    //1、创建分享参数
//    NSArray* imageArray = @[[UIImage imageNamed:@"placeholder"]];
//    //（注意：图片必须要在Xcode左边目录里面，名称必须要传正确，如果要分享网络图片，可以这样传iamge参数 images:@[@"http://mob.com/Assets/images/logo.png?v=20150320"]）
//    if (imageArray) {
//        
//        NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
//        [shareParams SSDKSetupShareParamsByText:nil
//                                         images:imageArray
//                                            url:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.cnbeta.com/articles/%@.htm",_newsId]]
//                                          title:_newsContent.title
//                                           type:SSDKContentTypeAuto];
//        //2、分享（可以弹出我们的分享菜单和编辑界面）
//        [ShareSDK showShareActionSheet:nil //要显示菜单的视图, iPad版中此参数作为弹出菜单的参照视图，只有传这个才可以弹出我们的分享菜单，可以传分享的按钮对象或者自己创建小的view 对象，iPhone可以传nil不会影响
//                                 items:nil
//                           shareParams:shareParams
//                   onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
//                       
//                       switch (state) {
//                           case SSDKResponseStateSuccess:
//                           {
//                               UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
//                                                                                   message:nil
//                                                                                  delegate:nil
//                                                                         cancelButtonTitle:@"确定"
//                                                                         otherButtonTitles:nil];
//                               [alertView show];
//                               break;
//                           }
//                           case SSDKResponseStateFail:
//                           {
//                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
//                                                                               message:[NSString stringWithFormat:@"%@",error]
//                                                                              delegate:nil
//                                                                     cancelButtonTitle:@"OK"
//                                                                     otherButtonTitles:nil, nil];
//                               [alert show];
//                               break;
//                           }
//                           default:
//                               break;
//                       }
//                   }];
//    }
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
