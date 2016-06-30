//
//  SettingsViewController.m
//  cnBeta
//
//  Created by hudy on 16/6/29.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import "SettingsViewController.h"
#import "HTMLCache.h"

@interface SettingsViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong)UITableView *settingsTableView;
@property (nonatomic, strong)NSArray *dataSource;
@property (nonatomic)float cacheSize;
@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"设置";
    _settingsTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 20, [[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.height-100) style:UITableViewStyleGrouped];
    [self.view addSubview:_settingsTableView];
    _settingsTableView.delegate = self;
    _settingsTableView.dataSource = self;
    _settingsTableView.bounces = NO;
    _settingsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _dataSource = @[@"清除缓存", @"反馈建议", @"关于"];
//    HTMLCache *cache = [HTMLCache sharedCache];
//    _cacheSize = [cache folderSizeOfCache];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    HTMLCache *cache = [HTMLCache sharedCache];
    _cacheSize = [cache folderSizeOfCache];
    [_settingsTableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }else {
        return 2;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (indexPath.section ==0) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"user"];
        cell.textLabel.text = _dataSource[0];
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2fMB", _cacheSize];
    }else {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"user"];
        cell.textLabel.text = _dataSource[indexPath.row+1];
    }
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section ==0) {
        if (_cacheSize < 0.01) {
            [self alertView:@"当前无缓存" cancel:@"OK"];
        } else {
            [self alertView:@"确定要清除缓存吗？" cancel:@"取消"];
        }
    }
}

- (void)alertView:(NSString *)alertString cancel:(NSString *)action
{
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:alertString message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *leftButton = [UIAlertAction actionWithTitle:action style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *rightButton = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self clearCache:YES];
    }];
    [alertView addAction:leftButton];
    if ([action isEqual: @"取消"]) {
        [alertView addAction:rightButton];
    }
    [self presentViewController:alertView animated:YES completion:nil];
}

- (void)clearCache:(BOOL)clear
{
    if (clear == YES) {
        HTMLCache *cache = [HTMLCache sharedCache];
        [cache clearCache];
        _cacheSize = 0;
        [self.settingsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:0], nil] withRowAnimation:UITableViewRowAnimationNone];
        //[_settingsTableView reloadData];
    }
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
