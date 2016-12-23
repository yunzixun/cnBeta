//
//  NewsListCell.m
//  cnBeta
//
//  Created by hudy on 16/7/3.
//  Copyright © 2016年 hudy. All rights reserved.
//


#import "NewsListCell.h"
<<<<<<< HEAD
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

=======
>>>>>>> parent of c5a4779... v1.3.3


@interface NewsListCell () <NSURLSessionDelegate>

@property (nonatomic, strong) UILabel      *time;
@property (strong, nonatomic) UIImageView *imageThumb;
@property (nonatomic, strong) UIImageView *newsCellCachedRectangle;
@property (nonatomic, strong) UIImageView *cmtImg;
@property (nonatomic, strong) UILabel     *cmtNum;
@property (nonatomic, strong) NSOperationQueue *queue;


@end

@implementation NewsListCell

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *cellId = @"cell";
    NewsListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil) {
        cell = [[NewsListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
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
        _newstitle.numberOfLines = 0;
        //[_newstitle setText:newsModel.title];
        _newstitle.font = [UIFont systemFontOfSize:15];
        _newstitle.textAlignment = NSTextAlignmentLeft;
        _newstitle.frame = CGRectMake(100, 10, ScreenWidth -10-100, 50);
        [self.contentView addSubview:_newstitle];
        
        //时间
        UILabel *time = [[UILabel alloc]init];
        _time = time;
        //_time.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        //[_time setText:newsModel.pubtime];
        _time.font = [UIFont systemFontOfSize:11];
        _time.textColor = [UIColor grayColor];
        _time.textAlignment = NSTextAlignmentLeft;
        _time.frame = CGRectMake(100, 60, 250, 10);
        [self.contentView addSubview:_time];
        
        //图片
        _newsCellCachedRectangle = [[UIImageView alloc] init];
        _newsCellCachedRectangle.frame = CGRectMake(10, 10, 79, 60);
        _newsCellCachedRectangle.layer.borderWidth = rectangleBordWidth;
        _newsCellCachedRectangle.layer.borderColor = rectangleBorderColor.CGColor;
        [self.contentView addSubview:_newsCellCachedRectangle];
        
        _imageThumb = [[UIImageView alloc]init];
        self.imageThumb.frame = CGRectMake(12, 12, 75, 56);
        [self.contentView addSubview:_imageThumb];
        //[self.imageThumb sd_setImageWithURL:[NSURL URLWithString:newsModel.thumb] placeholderImage:[UIImage imageNamed:@"placeholder"]];
        
        _cmtImg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"iPhone_TableViewCell_Reply_13x10_"]];
        _cmtImg.frame = CGRectMake(ScreenWidth - 50, 60, 15, 10);
        [self.contentView addSubview:_cmtImg];
        
        
        UILabel *cmtNum = [[UILabel alloc]init];
        _cmtNum = cmtNum;
        _cmtNum.font = [UIFont systemFontOfSize:10];
        _cmtNum.textColor = [UIColor grayColor];
        _cmtNum.textAlignment = NSTextAlignmentLeft;
        _cmtNum.frame = CGRectMake(ScreenWidth - 30, 60, 30, 10);
        [self.contentView addSubview:_cmtNum];
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

- (void)setNewsModel:(NewsModel *)newsModel
{
    _newsModel = newsModel;
    
    //新闻标题
<<<<<<< HEAD
    [_newstitle setText:[self pureTitle:newsModel.title]];
    _newstitle.font = NewsTitleFont;
    _newstitle.textColor = [newsModel.read boolValue] ? [UIColor grayColor] : [UIColor blackColor];

=======
    [_newstitle setText:newsModel.title];
    
>>>>>>> parent of c5a4779... v1.3.3
    
    //时间
    [_time setText:newsModel.pubtime];
    
    
    //图片
    if ([[CBDataBase sharedDataBase] isCached:self.newsModel.sid]) {
        self.newsModel.cacheStatus = @(CBArticleCacheStatusCached);
    }
    _newsCellCachedRectangle.hidden = [self.newsModel.cacheStatus integerValue] == CBArticleCacheStatusCached ? NO : YES;
    if ([CBAppSettings sharedSettings].imageWiFiOnlyEnabled && ![[AFNetworkReachabilityManager sharedManager] isReachableViaWiFi]) {
        NSString *imageUrl = [@"cnbeta://newsList.thumbnail?" stringByAppendingString:newsModel.thumb];
        [self.imageThumb sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"placeholder"]];

    } else {
        [self.imageThumb sd_setImageWithURL:[NSURL URLWithString:newsModel.thumb] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    }

    
    //评论数
    [_cmtNum setText:newsModel.comments];
<<<<<<< HEAD
    _cmtNum.font = CmtNumFont;
    
    [self downloadArticle];
=======
>>>>>>> parent of c5a4779... v1.3.3

}

- (void)downloadArticle
{
<<<<<<< HEAD
    if ([self.newsModel.cacheStatus integerValue] == CBArticleCacheStatusCached) {
        return;
    }
    if (![[AFNetworkReachabilityManager sharedManager] isReachableViaWiFi]) {
        return;
    }
    if (![CBAppSettings sharedSettings].prefetchEnabled ) {
        return;
    }
    if (self.queue) {
        [self.queue cancelAllOperations];
        self.queue = nil;
    }
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.name = @"cellCacheQueue";
    queue.maxConcurrentOperationCount = 1;
    self.queue = queue;
    
    NSString *url = [NSString stringWithFormat:@"http://www.cnbeta.com/articles/%@.htm", self.newsModel.sid];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:0 timeoutInterval:15];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:self.queue];
    
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            CBArticle *article = [[CBArticle alloc] init];
            TFHpple *hpple = [[TFHpple alloc] initWithHTMLData:data];
            [CBArticleParser parseArticle:article hpple:hpple];
            article.newsId = self.newsModel.sid;
            [[CBDataBase sharedDataBase] cacheArticle:article];
            
            self.newsModel.cacheStatus = @(CBArticleCacheStatusCached);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self refreshCacheStatus];
            });
            
            NSArray *imageUrls = article.imageUrls;
            for (NSString *url in imageUrls) {
                NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:0 timeoutInterval:15];
                NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
                NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:self.queue];

                config.protocolClasses = @[[CBHTTPURLProtocol class]];
                NSURLSessionTask *imageTask = [session dataTaskWithRequest:imageRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    if (!error) {
                        CBCachedURLResponse *cache = [[CBCachedURLResponse alloc] init];
                        cache.response = response;
                        cache.responseData = data;
                        [[CBObjectCache sharedCache] storeObject:cache forKey:imageRequest.URL.absoluteString];
                    }
                }];
                [imageTask resume];
            }
        } else {
            self.newsModel.cacheStatus = @(CBArticleCacheStatusFailed);
        }

    }];
    [task resume];
    

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
=======
    _hotNewsModel = hotNewsModel;

    //新闻标题
    [_newstitle setText:hotNewsModel.title];
    
    //时间
    [_time setText:hotNewsModel.inputtime];
    
    //图片
    [self.imageThumb sd_setImageWithURL:[NSURL URLWithString:hotNewsModel.thumb] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    
    //评论数
    [_cmtNum setText:hotNewsModel.comments];
}

>>>>>>> parent of c5a4779... v1.3.3
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
//We've attached screenshot(s) for your reference.
//I think thay are just some news about iPhone 7 and Apple didn't provide me with any pre-release versions of iPhone 7. You know, iPhone 7 attracts so much attention that you can see many similar news about iPhone 7 in almost all the news-apps or on the news websites. I've attached screenshots for your reference. And all the news resources in my app are from cnBeta.com and the news articles are written by technology enthusiasts. Even so, I will remove the news about iPhone 7 from the home page of my app.
@end

//OK, here is my explanation for this problem. Firstly, the API of cnBeta.com is open so we can get news data by using the API and that's why there are some third-party clients for cnBeta in AppStore. Secondly, when my app was rejected at the first time, one of your team members gave me some solutions to rights infringement, and one of the solutions is " include links to third-party news articles that launch in a web browser outside of the application", and I have done it. If my explanation is still not reasoned, I think I can do nothing anymore.

//This is not the first time that my app was rejected for this reason and I had made a very comprehensive explanation for this problem last time. I think they are just some news about iPhone 7 and Apple didn't provide me with any pre-release versions of iPhone 7. You know, iPhone 7 attracts so much attention that you can see many similar news about iPhone 7 in almost all the news-apps or on the news websites. I've attached screenshots for your reference. And all the news resources in my app are written by technology enthusiasts or reprinted from some cooperation media outlets. I really hope that iPhone 7 can be released sooner so that my app won't be rejected for this reason again and again.