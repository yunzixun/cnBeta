//
//  SettingsViewController.m
//  cnBeta
//
//  Created by hudy on 16/6/29.
//  Copyright © 2016年 hudy. All rights reserved.
//
#define cnBeta_APP_ID               @"1133433243"
#define cnBeta_APP_STORE_URL        @"https://itunes.apple.com/cn/app/id"cnBeta_APP_ID"?mt=8"
#define cnBeta_APP_STORE_REVIEW_URL @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id="cnBeta_APP_ID@"&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software"


#import "SettingsViewController.h"
#import "FileCache.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "NSString+iphoneType.h"
#import "SettingCell.h"
#import "SettingArrowItem.h"
#import "SettingSwitchItem.h"
#import "SettingGroup.h"

@interface SettingsViewController ()<UITableViewDelegate,UITableViewDataSource,MFMailComposeViewControllerDelegate>
@property (nonatomic, strong)UITableView *settingsTableView;
@property (nonatomic, strong)NSArray *dataSource;
@property (nonatomic)float cacheSize;
@property (nonatomic, strong)NSMutableArray *groupArray;
@end

@implementation SettingsViewController

- (NSMutableArray *)groupArray
{
    if (!_groupArray) {
        _groupArray = [[NSMutableArray alloc]init];
    }
    return _groupArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"设置";
    _settingsTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 20, [[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.height-100) style:UITableViewStyleGrouped];
    [self.view addSubview:_settingsTableView];
    _settingsTableView.delegate = self;
    _settingsTableView.dataSource = self;
    _settingsTableView.bounces = NO;
    _settingsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    if ([self.settingsTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.settingsTableView setSeparatorInset:UIEdgeInsetsZero];
        
    }
    if ([self.settingsTableView respondsToSelector:@selector(setLayoutMargins:)])  {
        [self.settingsTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    
    _dataSource = @[@"网络切换通知", @"清除缓存", @"反馈建议", @"去App Store给我们好评", @"关于"];
//    HTMLCache *cache = [HTMLCache sharedCache];
//    _cacheSize = [cache folderSizeOfCache];
    [self setupGroup0];
    [self setupGroup1];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    FileCache *cache = [FileCache sharedCache];
    _cacheSize = [cache folderSizeOfCache];
    
    SettingGroup * group = _groupArray[0];
    SettingItem *item = group.items[1];
    item.subtitle = [NSString stringWithFormat:@"%.2fMB", _cacheSize];
    [_settingsTableView reloadData];
}




- (void)setupGroup0
{
    //网络切换通知
    SettingItem *networkNotification = [SettingSwitchItem itemWithTitle:_dataSource[0]];

    //清除缓存
    SettingItem *clearCache = [SettingArrowItem itemWithTitle:_dataSource[1] subtitle:[NSString stringWithFormat:@"%.2fMB", _cacheSize]];
    clearCache.option = ^{
        [self showAlert];
    };
    
    SettingGroup *group0 = [[SettingGroup alloc]init];
    group0.items = @[networkNotification, clearCache];
    [self.groupArray addObject:group0];
}

- (void)setupGroup1
{
    //反馈建议
    SettingItem *feedback = [SettingArrowItem itemWithTitle:_dataSource[2]];
    feedback.option = ^{
        [self sendMailInApp];
    };
    
    //跳转AppStore
    SettingItem *remark = [SettingArrowItem itemWithTitle:_dataSource[3]];
    remark.option = ^{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:cnBeta_APP_STORE_URL]];
    };
    
    //关于
    SettingItem *about = [SettingArrowItem itemWithTitle:_dataSource[4]];
    about.option = ^{
        NSDictionary *infoDictionary = [[NSBundle mainBundle]infoDictionary];
        NSString *version = [NSString stringWithFormat:@"Version: %@", [infoDictionary objectForKey:@"CFBundleShortVersionString"]];
        [self alertView:@"西贝news For cnBeta"message:version cancel:@"OK"];
    };
    
    SettingGroup *group1 = [[SettingGroup alloc]init];
    group1.items = @[feedback, remark, about];
    [self.groupArray addObject:group1];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _groupArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    SettingGroup *group = _groupArray[section];
    return group.items.count;
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
    SettingCell *cell = [SettingCell cellWithTableView:tableView];
    SettingGroup *group = self.groupArray[indexPath.section];
    SettingItem *item = group.items[indexPath.row];
    
    cell.item = item;
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SettingGroup *group = self.groupArray[indexPath.section];
    SettingItem *item = group.items[indexPath.row];
    if (item.option) {
        item.option();
    }
        
}

- (void)showAlert
{
    if (_cacheSize < 0.01) {
        [self alertView:@"当前无缓存"message:nil cancel:@"OK"];
    } else {
        [self alertView:@"确定要清除缓存吗？"message:nil cancel:@"取消"];
    }
}

- (void)alertView:(NSString *)alertString message:(NSString *)msg cancel:(NSString *)action
{
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:alertString message:msg preferredStyle:UIAlertControllerStyleAlert];
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
        FileCache *cache = [FileCache sharedCache];
        [cache clearCache];
        _cacheSize = 0;
        [self.settingsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:0], nil] withRowAnimation:UITableViewRowAnimationNone];
        //[_settingsTableView reloadData];
    }
}

- (void)sendMailInApp
{
    if ([MFMailComposeViewController canSendMail]) { // 用户已设置邮件账户
        [self displayMailPicker]; // 调用发送邮件的代码
    }
}

//调出邮件发送窗口
- (void)displayMailPicker
{
    MFMailComposeViewController *mailPicker = [[MFMailComposeViewController alloc] init];
    mailPicker.mailComposeDelegate = self;
    
    //设置主题
    [mailPicker setSubject: @"反馈建议"];
    //添加收件人
    NSArray *toRecipients = [NSArray arrayWithObject: @"hudy0708@sjtu.edu.cn"];
    [mailPicker setToRecipients: toRecipients];
    //添加抄送
    NSArray *ccRecipients = [NSArray arrayWithObject:@"hudyseu@163.com"];
    [mailPicker setCcRecipients:ccRecipients];
//    //添加密送
//    NSArray *bccRecipients = [NSArray arrayWithObjects:@"fourth@example.com", nil];
//    [mailPicker setBccRecipients:bccRecipients];
//    
//    // 添加一张图片
//    UIImage *addPic = [UIImage imageNamed: @"Icon@2x.png"];
//    NSData *imageData = UIImagePNGRepresentation(addPic);            // png
    //关于mimeType：http://www.iana.org/assignments/media-types/index.html
//    [mailPicker addAttachmentData: imageData mimeType: @"" fileName: @"Icon.png"];
    
    //添加一个pdf附件
//    NSString *file = [self fullBundlePathFromRelativePath:@"高质量C++编程指南.pdf"];
//    NSData *pdf = [NSData dataWithContentsOfFile:file];
//    [mailPicker addAttachmentData: pdf mimeType: @"" fileName: @"高质量C++编程指南.pdf"];
    
    NSString *emailBody = [NSString stringWithFormat:@"系统版本：%@\n手机型号：%@\n", [[UIDevice currentDevice] systemVersion], [NSString iphoneType]] ;
    [mailPicker setMessageBody:emailBody isHTML:NO];
    [self presentViewController:mailPicker animated:YES completion:nil];
    
}



#pragma mark - 实现 MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    //关闭邮件发送窗口
    switch (result)
    {
        case MFMailComposeResultCancelled: // 用户取消编辑
            NSLog(@"Mail send canceled...");
            break;
        case MFMailComposeResultSaved: // 用户保存邮件
            NSLog(@"Mail saved...");
            break;
        case MFMailComposeResultSent: // 用户点击发送
            NSLog(@"Mail sent...");
            break;
        case MFMailComposeResultFailed: // 用户尝试保存或发送邮件失败
            NSLog(@"Mail send errored: %@...", [error localizedDescription]);
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
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
