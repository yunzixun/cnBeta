//
//  collectionTableViewController.m
//  cnBeta
//
//  Created by hudy on 16/7/8.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "collectionTableViewController.h"
#import "contentViewController.h"
#import "collectionTableViewCell.h"
#import "collectionModel.h"
#import "DataBase.h"

@interface collectionTableViewController ()

@property (nonatomic, strong)NSMutableArray *newsCollection;
@property (nonatomic, strong)DataBase *collection;
@end

@implementation collectionTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
    self.title = @"收藏";
    self.tableView.rowHeight = 60.0f;
    self.tableView.separatorColor = [UIColor grayColor];
    self.tableView.tableFooterView=[[UIView alloc]init];
    
    _newsCollection = [NSMutableArray array];
        // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetchCollection];
    [self.tableView reloadData];
}

- (void)fetchCollection
{
    _collection = [DataBase sharedDataBase];
    _newsCollection = [_collection display];
    }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_newsCollection count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cell";
    collectionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    // Configure the cell...
    cell.newsInfo = _newsCollection[[_newsCollection count]-indexPath.row-1];
    return cell;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[contentViewController class]]) {
        contentViewController *contentvc = (contentViewController *)segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        contentvc.hidesBottomBarWhenPushed = YES;
        collectionModel *currentNews = _newsCollection[[_newsCollection count]-indexPath.row-1];
        contentvc.newsId = currentNews.sid;
        //contentvc.comments = currentNews.comments;
        contentvc.newsTitle = currentNews.title;
            }
}


#pragma mark - Action
- (IBAction)clearCollection:(id)sender {
    [_collection deleteAll];
    _newsCollection = nil;
    [self.tableView reloadData];
}

@end
