//
//  NewsListCell.m
//  cnBeta
//
//  Created by hudy on 16/7/3.
//  Copyright © 2016年 hudy. All rights reserved.
//

#define SCREEN_WIDTH                    [UIScreen mainScreen].bounds.size.width

#import "NewsListCell.h"


@interface NewsListCell ()

@property (nonatomic,strong)UILabel      *time;
@property (strong, nonatomic)UIImageView *imageThumb;
@property (nonatomic, strong)UIImageView *cmtImg;
@property (nonatomic, strong)UILabel     *cmtNum;


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
        _newstitle.frame = CGRectMake(100, 10, SCREEN_WIDTH -10-100, 50);
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
        _imageThumb = [[UIImageView alloc]init];
        self.imageThumb.frame = CGRectMake(12, 12, 75, 56);
        [self.contentView addSubview:_imageThumb];
        //[self.imageThumb sd_setImageWithURL:[NSURL URLWithString:newsModel.thumb] placeholderImage:[UIImage imageNamed:@"placeholder"]];
        
        _cmtImg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"iPhone_TableViewCell_Reply_13x10_"]];
        _cmtImg.frame = CGRectMake(SCREEN_WIDTH - 50, 60, 15, 10);
        [self.contentView addSubview:_cmtImg];
        
        
        UILabel *cmtNum = [[UILabel alloc]init];
        _cmtNum = cmtNum;
        _cmtNum.font = [UIFont systemFontOfSize:10];
        _cmtNum.textColor = [UIColor grayColor];
        _cmtNum.textAlignment = NSTextAlignmentLeft;
        _cmtNum.frame = CGRectMake(SCREEN_WIDTH - 30, 60, 30, 10);
        [self.contentView addSubview:_cmtNum];
    }
    return self;
}
//- (void)setNewsModel:(DataModel *)newsModel
//{
//    _newsModel = newsModel;
//    for (UILabel *label in self.contentView.subviews) {
//        [label removeFromSuperview];
//    }
//    //新闻标题
//    _newstitle = [[UILabel alloc]initWithFrame:CGRectMake(100, 10, SCREEN_WIDTH-10-100, 50)];
//    _newstitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    _newstitle.numberOfLines = 3;
//    [_newstitle setText:newsModel.title];
//    _newstitle.font = [UIFont systemFontOfSize:16];
//    _newstitle.textAlignment = NSTextAlignmentLeft;
//    [self.contentView addSubview:_newstitle];
//    //时间
//    _time = [[UILabel alloc]initWithFrame:CGRectMake(100, 60, 250, 10)];
//    _time.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    [_time setText:newsModel.pubtime];
//    _time.font = [UIFont systemFontOfSize:11];
//    _time.textColor = [UIColor grayColor];
//    _time.textAlignment = NSTextAlignmentLeft;
//    [self.contentView addSubview:_time];
//    //NSLog(@"%@", newsModel.thumb);
//    //图片
//    _imageThumb = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 80, 60)];
//    [self.contentView addSubview:_imageThumb];
//    [self.imageThumb sd_setImageWithURL:[NSURL URLWithString:newsModel.thumb] placeholderImage:[UIImage imageNamed:@"placeholder"]];
//}

- (void)setNewsModel:(DataModel *)newsModel
{
    _newsModel = newsModel;
    
    //新闻标题
    [_newstitle setText:newsModel.title];
    
    
    //时间
    [_time setText:newsModel.pubtime];
    
    
    //图片
    [self.imageThumb sd_setImageWithURL:[NSURL URLWithString:newsModel.thumb] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    
    //评论数
    [_cmtNum setText:newsModel.comments];
    
        
    
    
    
    
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:newsModel.thumb]  options:NSDataReadingMappedIfSafe error:NULL];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            UIImage *image = [UIImage imageWithData:imageData];
//            self.imageThumb.image = image;
//        });
//    });
}

- (void)setHotNewsModel:(HotNewsModel *)hotNewsModel
{
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