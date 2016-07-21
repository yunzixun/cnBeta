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

//#import <ShareSDK/ShareSDK.h>
//#import <ShareSDKUI/ShareSDK+SSUI.h>

@interface contentViewController ()

@property (nonatomic, copy)NSString *contentHTMLString;
@property (nonatomic, copy)NSString *contentURL;
@property (nonatomic, copy) NSString *sn;
@property (nonatomic, strong)NewsContentModel *newsContent;
@property (nonatomic,strong)DataBase *collection;
@property (nonatomic,strong)collectionModel *news;

@property (weak, nonatomic) IBOutlet UIButton *collect;

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
    
    
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
    
    NSMutableString *allTitleStr =[NSMutableString stringWithString:@"<style type='text/css'> p.thicker{font-weight: 500}p.light{font-weight: 0}p{font-size: 108%}h2 {font-size: 120%}h3 {font-size: 80%}</style> <h2 class = 'thicker'>title</h2><h3>hehe      lala      gaga</h3>"];
    
    [allTitleStr replaceOccurrencesOfString:@"title" withString:_newsContent.title options:NSCaseInsensitiveSearch range:[allTitleStr rangeOfString:@"title"]];
    [allTitleStr replaceOccurrencesOfString:@"hehe" withString:_newsContent.source options:NSCaseInsensitiveSearch range:[allTitleStr rangeOfString:@"hehe"]];
    [allTitleStr replaceOccurrencesOfString:@"lala" withString:_newsContent.time options:NSCaseInsensitiveSearch range:[allTitleStr rangeOfString:@"lala"]];
    [allTitleStr replaceOccurrencesOfString:@"gaga" withString:[NSString stringWithFormat:@"%@条评论", _newsContent.comments] options:NSCaseInsensitiveSearch range:[allTitleStr rangeOfString:@"gaga"]];
    
    NSMutableString *head = (NSMutableString *)@"<head><style>img{width:360px !important;}</style></head>";
    _contentHTMLString = [[[head stringByAppendingString:allTitleStr] stringByAppendingString:_newsContent.hometext] stringByAppendingString:_newsContent.bodytext];
    [_contentWebView loadHTMLString:_contentHTMLString baseURL:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_spinner stopAnimating];
        //[_spinner removeFromSuperview];
        //_spinner.hidden = YES;
    });
    
    
}





#pragma mark - Actions

- (IBAction)showComments:(id)sender
{
    [self.navigationController pushViewController:[[commentViewController alloc]initWithSid:_newsId andSN:_sn] animated:YES];
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
