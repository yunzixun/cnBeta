//
//  CBPadNewsListCell.m
//  cnBeta
//
//  Created by hudy on 2017/2/12.
//  Copyright © 2017年 hudy. All rights reserved.
//

#import "CBPadNewsListCell.h"
#import "CBAppearanceManager.h"
#import "CBAppSettings.h"
#import "Constant.h"
#import "CBHTTPRequester.h"
#import "CBArticle.h"
#import "CBArticleParser.h"
#import "CBDataBase.h"
#import "CBCachedURLResponse.h"
#import "CBObjectCache.h"
#import "CBHTTPURLProtocol.h"
#import "CBURLRequestWrapperOperation.h"
#import "NSString+removehtml.h"


@interface CBPadNewsListCell () <NSURLSessionDelegate>

@property (nonatomic, strong) UILabel     *newstitle;
@property (nonatomic, strong) UILabel     *summary;
@property (nonatomic, strong) UILabel     *time;
@property (nonatomic, strong) UIImageView *imageThumb;
@property (nonatomic, strong) UIImageView *newsCellCachedRectangle;
@property (nonatomic, strong) UIImageView *cmtImg;
@property (nonatomic, strong) UILabel     *cmtNum;
@property (nonatomic, strong) NSOperationQueue *queue;


@end


@implementation CBPadNewsListCell

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *cellId = @"cell";
    CBPadNewsListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil) {
        cell = [[CBPadNewsListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        //新闻标题
        UILabel *newstitle = [[UILabel alloc]init];
        _newstitle = newstitle;
        //_newstitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _newstitle.numberOfLines = 2;
        _newstitle.textAlignment = NSTextAlignmentLeft;
        _newstitle.frame = CGRectMake(150, 5, ScreenWidth -30-150, 60);
        [self.contentView addSubview:_newstitle];
        
        //摘要
        UILabel *summary = [[UILabel alloc] init];
        _summary = summary;
        _summary.textColor = [UIColor grayColor];
        _summary.numberOfLines = 1;
        _summary.textAlignment = NSTextAlignmentLeft;
        _summary.frame = CGRectMake(150, 65, ScreenWidth - 30 - 150, 25);
        [self.contentView addSubview:_summary];
        
        //时间
        UILabel *time = [[UILabel alloc]init];
        _time = time;
        //_time.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _time.textColor = [UIColor grayColor];
        _time.textAlignment = NSTextAlignmentLeft;
        _time.frame = CGRectMake(150, 90, 150, 20);
        [self.contentView addSubview:_time];
        
        //图片
        _newsCellCachedRectangle = [[UIImageView alloc] init];
        _newsCellCachedRectangle.frame = CGRectMake(19, 19, 102, 82);
        _newsCellCachedRectangle.layer.borderWidth = rectangleBordWidth;
        _newsCellCachedRectangle.layer.borderColor = rectangleBorderColor.CGColor;
        [self.contentView addSubview:_newsCellCachedRectangle];
        
        _imageThumb = [[UIImageView alloc]init];
        self.imageThumb.frame = CGRectMake(20, 20, 100, 80);
        [self.contentView addSubview:_imageThumb];
        
        _cmtImg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"iPadTable_SP_Cell_CommentCount_18x13_"]];
        _cmtImg.frame = CGRectMake(ScreenWidth - 70, 97, 18, 13);
        [self.contentView addSubview:_cmtImg];
        
        //评论数
        UILabel *cmtNum = [[UILabel alloc]init];
        _cmtNum = cmtNum;
        _cmtNum.textColor = [UIColor grayColor];
        _cmtNum.textAlignment = NSTextAlignmentLeft;
        _cmtNum.frame = CGRectMake(ScreenWidth - 50, 95, 20, 15);
        [self.contentView addSubview:_cmtNum];
        
//        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//            _cmtImg.frame = CGRectMake(250, 60, 15, 10);
//            _cmtNum.frame = CGRectMake(270, 60, 30, 10);
//        }
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    if (self.queue) {
        [self.queue cancelAllOperations];
        self.queue = nil;
    }
}

- (void)setTitleColor:(UIColor *)titleColor
{
    self.newstitle.textColor = titleColor;
}

- (void)setNewsModel:(NewsModel *)newsModel
{
    [super setNewsModel:newsModel];
    //新闻标题
    [_newstitle setText:[self pureTitle:newsModel.title]];
    _newstitle.font = PadNewsTitleFont;
    if ([newsModel.read boolValue]) {
        _newstitle.textColor = [UIColor grayColor];
    } else {
        _newstitle.textColor = [UIColor cb_textColor];
    }
    
    //摘要
    [_summary setText:newsModel.hometext];
    _summary.font = PadNewsTimeFont;

    //时间
    [_time setText:newsModel.inputtime];
    _time.font = PadNewsTimeFont;
    
    //图片
    [self updateCacheStatus:^{
        _newsCellCachedRectangle.hidden = [self.newsModel.cacheStatus integerValue] == CBArticleCacheStatusCached ? NO : YES;
    }];
    if ([CBAppSettings sharedSettings].imageWiFiOnlyEnabled && ![[AFNetworkReachabilityManager sharedManager] isReachableViaWiFi]) {
        NSString *imageUrl = [@"cnbeta://newsList.thumbnail?" stringByAppendingString:newsModel.thumb];
        [self.imageThumb sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"placeholder"]];
        
    } else {
        [self.imageThumb sd_setImageWithURL:[NSURL URLWithString:newsModel.thumb] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    }
    
    
    //评论数
    [_cmtNum setText:newsModel.comments];
    _cmtNum.font = PadCmtNumFont;

    [self downloadArticle];
    
}

- (NSOperationQueue *)queue
{
    if (!_queue) {
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        queue.name = @"cellQueue";
        queue.maxConcurrentOperationCount = 1;
        _queue = queue;
    }
    return _queue;
}

- (void)updateCacheStatus:(void (^)())completion
{
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (![self.newsModel.cacheStatus  isEqual: @(CBArticleCacheStatusCached)]) {
            if ([[CBDataBase sharedDataBase] isCached:self.newsModel.sid]) {
                self.newsModel.cacheStatus = @(CBArticleCacheStatusCached);
            }else {
                self.newsModel.cacheStatus = @(CBArticleCacheStatusFailed);
            }
        }
        
        if (!completion) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completion();
        });
    });
    
}

- (void)downloadArticle
{
    if ([self.newsModel.cacheStatus integerValue] == CBArticleCacheStatusCached) {
        return;
    }
    if (![[AFNetworkReachabilityManager sharedManager] isReachableViaWiFi]) {
        return;
    }
    if (![CBAppSettings sharedSettings].prefetchEnabled ) {
        return;
    }
    //    if (self.queue) {
    //        [self.queue cancelAllOperations];
    //        self.queue = nil;
    //    }
    
    NSString *url = [NSString stringWithFormat:@"http://www.cnbeta.com/articles/%@.htm", self.newsModel.sid];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:0 timeoutInterval:15];
    
    CBURLRequestWrapperOperation *articleOperation = [CBURLRequestWrapperOperation operationWithURLRequest:request];
    [articleOperation createTaskWithCompletionBlock:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (!error) {
            CBArticle *article = [[CBArticle alloc] init];
            TFHpple *hpple = [[TFHpple alloc] initWithHTMLData:responseObject];
            [CBArticleParser parseArticle:article hpple:hpple];
            article.newsId = self.newsModel.sid;
            [[CBDataBase sharedDataBase] cacheArticle:article];
            
            self.newsModel.cacheStatus = @(CBArticleCacheStatusCached);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self refreshCacheStatus];
            });
            
            // 自动下载所有图片
            NSArray *imageUrls = article.imageUrls;
            for (NSString *url in imageUrls) {
                NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:0 timeoutInterval:15];
                CBURLRequestWrapperOperation *imgOperation = [CBURLRequestWrapperOperation operationWithURLRequest:imageRequest];
                [imgOperation createTaskWithCompletionBlock:^(NSURLResponse *response, id responseObject, NSError *error) {
                    //                    if (!error) {
                    //                        CBCachedURLResponse *cache = [[CBCachedURLResponse alloc] init];
                    //                        cache.response = response;
                    //                        cache.responseData = responseObject;
                    //                        [[CBObjectCache sharedCache] storeObject:cache forKey:imageRequest.URL.absoluteString];
                    //                    }
                    
                }];
                [self.queue addOperation:imgOperation];
            }
            
        } else {
            self.newsModel.cacheStatus = @(CBArticleCacheStatusFailed);
            
        }
    }];
    [self.queue addOperation:articleOperation];
    
}

- (void)refreshCacheStatus
{
    if ([self.newsModel.cacheStatus integerValue] == CBArticleCacheStatusCached) {
        self.newsCellCachedRectangle.hidden = NO;
    }
}


- (NSString *)pureTitle:(NSString *)title
{
    if ([title characterAtIndex:0] == '<') {
        NSRange range = [title rangeOfString:@">"];
        NSString *tmp = [title substringFromIndex:range.location+range.length];
        range = [tmp rangeOfString:@"<"];
        NSString *resultString = [tmp substringToIndex:range.location];
        return resultString;
    }
    else{
        return title;
    }
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
