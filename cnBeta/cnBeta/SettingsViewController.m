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
#import "CBObjectCache.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "NSString+iphoneType.h"
#import "SettingCell.h"
#import "SettingArrowItem.h"
#import "SettingSwitchItem.h"
#import "SettingGroup.h"
#import "CBAppSettings.h"
#import "CBAppearanceManager.h"
#import "CBDataBase.h"

@interface SettingsViewController ()<UITableViewDelegate, UITableViewDataSource, SwitchControlDelegate, MFMailComposeViewControllerDelegate>
{
    NSInteger _index;
}
@property (nonatomic, strong)UITableView *settingsTableView;
@property (nonatomic, strong)NSArray *dataSource;
@property (nonatomic)float cacheSize;
@property (nonatomic, strong)NSMutableArray *groupArray;
@property (nonatomic, strong)CBAppSettings *settings;
@property (nonatomic, strong)NSDictionary *switchDic;
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
    _settings = [CBAppSettings sharedSettings];
    
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
    
    
    _dataSource = @[@"手势操作", @"网络切换通知", @"WiFi网络下开启预载", @"仅WiFi网络下加载图片", @"显示文章来源", @"自动收藏评论过的文章", @"使用细体文字", @"自动清理7天前缓存", @"清除缓存", @"反馈建议", @"去App Store给我们好评", @"关于"];
    _switchDic = @{@"手势操作": @(CBGesture), @"网络切换通知": @(CBNetworkNotification), @"WiFi网络下开启预载": @(CBPrefetch), @"仅WiFi网络下加载图片": @(CBImageWiFiOnly), @"显示文章来源":@(CBSourceDisplay), @"自动收藏评论过的文章": @(CBAutoCollection), @"使用细体文字": @(CBFontChange), @"自动清理7天前缓存":@(CBAutoClear)};
    _index = 0;

    [self setupGroup0];
    [self setupGroup1];
    [self setupGroup2];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    FileCache *cache = [FileCache sharedCache];
    _cacheSize = [cache folderSizeOfCache];
    
    CBObjectCache *objectCache = [CBObjectCache sharedCache];
    _cacheSize += [objectCache cacheSize];
    
    SettingGroup * group = _groupArray[1];
    SettingItem *item = [group.items lastObject];
    item.subtitle = [NSString stringWithFormat:@"%.2fMB", _cacheSize];
    
    [_settingsTableView reloadData];
}




- (void)setupGroup0
{
    //手势
    SettingItem *gesture = [SettingSwitchItem itemWithTitle:_dataSource[_index++]];
    
    //网络切换通知
    SettingItem *networkNotification = [SettingSwitchItem itemWithTitle:_dataSource[_index++]];
    
    //WiFi下预载文章
    SettingItem *prefetch = [SettingSwitchItem itemWithTitle:_dataSource[_index++]];
    
    //仅WiFi下加载图片
    SettingItem *imageWiFiOnly = [SettingSwitchItem itemWithTitle:_dataSource[_index++]];
    
    //显示文章来源
    SettingItem *sourceDisplay = [SettingSwitchItem itemWithTitle:_dataSource[_index++]];

    //自动收藏
    SettingItem *autoCollection = [SettingSwitchItem itemWithTitle:_dataSource[_index++]];
    
    //使用细体文字
    SettingItem *fontChange = [SettingSwitchItem itemWithTitle:_dataSource[_index ++]];
    
    SettingGroup *group0 = [[SettingGroup alloc]init];
    
    if ([[UIDevice currentDevice] systemVersion].floatValue >= 8.0) {
        group0.items = @[gesture, networkNotification, prefetch, imageWiFiOnly, sourceDisplay, autoCollection, fontChange];
    } else {
        group0.items = @[gesture, networkNotification, autoCollection];
    }
    [self.groupArray addObject:group0];
}

- (void)setupGroup1
{
    //自动清理
    SettingItem *autoClear = [SettingSwitchItem itemWithTitle:_dataSource[_index++]];
    
    //清除缓存
    SettingItem *clearCache = [SettingArrowItem itemWithTitle:_dataSource[_index++] subtitle:[NSString stringWithFormat:@"%.2fMB", _cacheSize]];
    clearCache.option = ^{
        [self showAlert];
    };
    SettingGroup *group1 = [[SettingGroup alloc] init];
    group1.items = @[autoClear, clearCache];
    [self.groupArray addObject:group1];
    
}

- (void)setupGroup2
{
    //反馈建议
    SettingItem *feedback = [SettingArrowItem itemWithTitle:_dataSource[_index++]];
    feedback.option = ^{
        [self sendMailInApp];
    };
    
    //跳转AppStore
    SettingItem *remark = [SettingArrowItem itemWithTitle:_dataSource[_index++]];
    remark.option = ^{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:cnBeta_APP_STORE_URL]];
    };
    
    //关于
    SettingItem *about = [SettingArrowItem itemWithTitle:_dataSource[_index++]];
    about.option = ^{
        NSDictionary *infoDictionary = [[NSBundle mainBundle]infoDictionary];
        NSString *version = [NSString stringWithFormat:@"Version: %@", [infoDictionary objectForKey:@"CFBundleShortVersionString"]];
        [self alertView:@"西贝news"message:version cancel:@"OK"];
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
    return 10;
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
    cell.delegate = self;
    SettingGroup *group = self.groupArray[indexPath.section];
    SettingItem *item = group.items[indexPath.row];
    
    cell.item = item;
    
    return cell;
}


#pragma mark - SwitchControlDelegate

- (void)setState:(BOOL)isOn forSwitch:(NSString *)switchName
{
    switch ([_switchDic[switchName] intValue]) {
        case CBGesture:
            _settings.gestureEnabled = isOn;
            break;
            
        case CBNetworkNotification:
            _settings.networkNotificationEnabled = isOn;
            break;
            
        case CBPrefetch:
            _settings.prefetchEnabled = isOn;
            break;
            
        case CBImageWiFiOnly:
            _settings.imageWiFiOnlyEnabled = isOn;
            break;
            
        case CBSourceDisplay:
            _settings.sourceDisplayEnabled = isOn;
            break;
            
        case CBAutoCollection:
            _settings.autoCollectionEnabled = isOn;
            break;
            
        case CBFontChange:
            _settings.thinFontEnabled = isOn;
            break;
            
        case CBAutoClear:
            _settings.autoClearEnabled = isOn;
            break;
            
        default:
            break;
    }
}

- (BOOL)stateForSwitch:(NSString *)switchName
{
    BOOL status;
    switch ([_switchDic[switchName] intValue]) {
        case CBGesture:
            status = _settings.gestureEnabled;
            //NSLog(@"gesture:%d", status? 1:0);
            break;
            
        case CBNetworkNotification:
            status = _settings.networkNotificationEnabled;
            break;
            
        case CBPrefetch:
            status = _settings.prefetchEnabled;
            break;
            
        case CBImageWiFiOnly:
            status = _settings.imageWiFiOnlyEnabled;
            break;
            
        case CBSourceDisplay:
            status = _settings.sourceDisplayEnabled;
            break;
            
        case CBAutoCollection:
            status = _settings.autoCollectionEnabled;
            break;
          
        case CBFontChange:
            status = _settings.thinFontEnabled;
            break;
            
        case CBAutoClear:
            status = _settings.autoClearEnabled;
            break;
            
        default:
            break;
    }
    return status;
}

- (void)reloadTableView
{
    if ([[UIDevice currentDevice] systemVersion].floatValue >= 8.0) {
        [[CBAppearanceManager sharedManager] updateCBFont];
        [self.settingsTableView reloadData];
    }
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
//        CBObjectCache *objectCache = [CBObjectCache sharedCache];
//        [objectCache clearDiskCache];
        _cacheSize = 0;
        
        SettingGroup * group = _groupArray[1];
        
        SettingItem *item = [group.items lastObject];
        item.subtitle = [NSString stringWithFormat:@"%.2fMB", _cacheSize];
        
        [self.settingsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:[group.items indexOfObject:item] inSection:1], nil] withRowAnimation:UITableViewRowAnimationNone];
        //[_settingsTableView reloadData];
        [[CBDataBase sharedDataBase] clearExpiredCache];
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


//- (void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//    //是否是第一次进入setting界面
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    if (![defaults boolForKey:@"everLaunched"]) {
//        [defaults setBool:YES forKey:@"everLaunched"];
//        [defaults synchronize];
//    }
//    
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
