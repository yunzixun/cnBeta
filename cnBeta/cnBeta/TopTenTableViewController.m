//
//  TopTenTableViewController.m
//  cnBeta
//
//  Created by hudy on 16/6/28.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "TopTenTableViewController.h"
#import "UIViewController+DownloadNews.h"
#import "contentViewController.h"
#import "NSString+MD5.h"

static NSString *const newsListURLString = @"http://www.cnbeta.com/capi?app_key=10002&format=json&method=phone.Top10&timestamp=1467084579&v=1.0&sign=99dc72d30dfb1781fc3238c95adc0436";

@interface TopTenTableViewController ()
@property (nonatomic, assign) NSUInteger RowCount;
@property (nonatomic, strong) NSArray *newsList;
@end

@implementation TopTenTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
    self.title = @"推荐";
    self.tableView.rowHeight = 90.0f;
    self.tableView.separatorColor = [UIColor grayColor];
    _RowCount = 10;
    self.newsList = [[NSMutableArray alloc]init];
    [self loadData];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)loadData
{
    //Unix时间戳
    UInt64 timestamp = (UInt64)[[NSDate date]timeIntervalSince1970];
//    UInt64 timestamp = 1467084579;
//
//    //md5加密
//    NSString *md5String = [NSString stringWithFormat:@"app_key=10002&format=json&method=phone.Top10&timestamp=%llu&v=1.0", timestamp ];
//    NSString *sign = [md5String MD5];
    NSString *listURL = [NSString stringWithFormat:@"http://www.cnbeta.com/more?_=%llu&page=1&type=dig", timestamp];
//    NSLog(@"%@",listURL);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:listURL]];
    [request setValue:@"http://www.cnbeta.com/" forHTTPHeaderField:@"Referer"];
    [request setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            _newsList = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        }
    }];
    [task resume];
    
//    [self requestWithURL:listURL completion:^(NSData *data, NSError *error) {
//        if (!error) {
//            _newsList = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//        }
//    }];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.RowCount;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"topTen";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    
    // Configure the cell...
    for (UILabel *label in cell.contentView.subviews) {
        [label removeFromSuperview];
    }
    UILabel *newstitle = [[UILabel alloc]initWithFrame:CGRectMake(20, 10, 340, 50)];
    newstitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    newstitle.numberOfLines = 3;
    [newstitle setText:self.newsList[indexPath.row][@"title"]];
    newstitle.font = [UIFont systemFontOfSize:16];
    newstitle.textAlignment = NSTextAlignmentLeft;
    [cell.contentView addSubview:newstitle];
    
    UIImageView *eyeIcon = [[UIImageView alloc]initWithFrame:CGRectMake(20, 70, 10, 10)];
    eyeIcon.image = [UIImage imageNamed:@"eye.png"];
    [cell.contentView addSubview:eyeIcon];
    
    UILabel *counter = [[UILabel alloc]initWithFrame:CGRectMake(25, 70, 100, 10)];
    [counter setText:self.newsList[indexPath.row][@"counter"]];
    counter.font = [UIFont systemFontOfSize:11];
    counter.textAlignment = NSTextAlignmentLeft;
    [cell.contentView addSubview:counter];
    
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
