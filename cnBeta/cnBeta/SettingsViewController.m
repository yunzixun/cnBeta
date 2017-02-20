//
//  SettingsViewController.m
//  cnBeta
//
//  Created by hudy on 16/6/29.
//  Copyright © 2016年 hudy. All rights reserved.
//


#import "SettingsViewController.h"
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
#import "Constant.h"
#import "purchaseViewController.h"
#import "NightModeTimeSettingViewController.h"
#import "UIColor+CBColor.h"

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
@property (nonatomic, weak) UILabel *cacheLabel;
@property (nonatomic, weak) UILabel *nightModeTimeLabel;
@end

@implementation SettingsViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

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
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @" ";
    self.navigationItem.backBarButtonItem = backItem;

    _settings = [CBAppSettings sharedSettings];
    
    _settingsTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 20, ScreenWidth, ScreenHeight) style:UITableViewStyleGrouped];
    [self.view addSubview:_settingsTableView];
    _settingsTableView.delegate = self;
    _settingsTableView.dataSource = self;
    _settingsTableView.backgroundColor = [UIColor cb_settingViewBackgroundColor];
    _settingsTableView.separatorColor = [UIColor cb_settingTableViewSeparatorColor];
    _settingsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    if ([self.settingsTableView respondsToSelector:@selector(setLayoutMargins:)])  {
        [self.settingsTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged) name:CBAppSettingThemeChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unlockNightMode) name:CBPurchaseStateChangedNotification object:nil];
    
    _dataSource = @[@"开启更新提醒", @"网络切换通知", @"WiFi网络下开启预载", @"仅WiFi网络下加载图片", @"显示文章来源", @"自动收藏评论过的文章", @"使用细体文字", @"新闻/评论滑动全屏", @"自动清理7天前缓存", @"清除缓存", @"鼓励一下开发者", @"反馈建议", @"去App Store给我们好评", @"关于"];
    _switchDic = @{@"开启更新提醒": @(CBUpdateNotification), @"网络切换通知": @(CBNetworkNotification), @"WiFi网络下开启预载": @(CBPrefetch), @"仅WiFi网络下加载图片": @(CBImageWiFiOnly), @"显示文章来源":@(CBSourceDisplay), @"自动收藏评论过的文章": @(CBAutoCollection), @"使用细体文字": @(CBFontChange), @"新闻/评论滑动全屏": @(CBFullScreenWhenScrolling), @"夜间模式":@(CBNightMode), @"自动切换夜间模式": @(CBAutoNightMode), @"自动清理7天前缓存":@(CBAutoClear)};
    _index = 0;

    [self setupGroup0];
    [self setupGroup1];
    [self setupGroup2];
    [self setupGroup3];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[CBObjectCache sharedCache] calculateCacheSize:^(float size) {
        self.cacheSize = size;
        [self.cacheLabel setText:[NSString stringWithFormat:@"%.2fMB", size]];
    }];
    [self.nightModeTimeLabel setText:[NSString stringWithFormat:@"%@-%@", [[NSUserDefaults standardUserDefaults] stringForKey:startTimeKey], [[NSUserDefaults standardUserDefaults] stringForKey:endTimeKey]]];
}

- (void)themeChanged
{
    _settingsTableView.backgroundColor = [UIColor cb_settingViewBackgroundColor];
    _settingsTableView.separatorColor = [UIColor cb_settingTableViewSeparatorColor];
    //self.nightModeTimeLabel = nil;
    [_settingsTableView reloadData];
}

- (void)unlockNightMode
{
    //[self setupGroup1];
    [_settingsTableView reloadData];
}

- (void)setupGroup0
{
    //更新提醒
    SettingItem *updateNotification = [SettingSwitchItem itemWithTitle:_dataSource[_index++]];
    
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
    
    //滑动全屏
    SettingItem *fullScreenWhenScrolling = [SettingSwitchItem itemWithTitle:_dataSource[_index++]];
    
    SettingGroup *group0 = [[SettingGroup alloc]init];
    
    if ([[UIDevice currentDevice] systemVersion].floatValue >= 8.0) {
        group0.items = @[updateNotification, networkNotification, prefetch, imageWiFiOnly, sourceDisplay, autoCollection, fontChange, fullScreenWhenScrolling];
    } else {
        group0.items = @[updateNotification, networkNotification, prefetch, imageWiFiOnly, sourceDisplay, autoCollection, fullScreenWhenScrolling];
    }
    [self.groupArray addObject:group0];
}

- (void)setupGroup1
{
    //夜间模式
    SettingItem *nightMode = [SettingSwitchItem itemWithTitle:@"夜间模式"];
    
    //自动切换夜间模式
    SettingItem *autoNightMode = [SettingSwitchItem itemWithTitle:@"自动切换夜间模式"];
    
    //设置夜间模式起止时间
    SettingItem *timeSetting = [SettingArrowItem itemWithTitle:nil];
    timeSetting.option = ^{
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        NightModeTimeSettingViewController *nightModeSettingvc = [mainStoryboard instantiateViewControllerWithIdentifier:@"NightModeTimeSettingViewController"];
        nightModeSettingvc.title = @"夜间模式自动开启时段";
        nightModeSettingvc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:nightModeSettingvc animated:YES];
    };
    
    SettingGroup *group1 = [[SettingGroup alloc] init];
    group1.items = @[nightMode, autoNightMode, timeSetting];
    [self.groupArray insertObject:group1 atIndex:1];
}

- (void)setupGroup2
{
    //自动清理
    SettingItem *autoClear = [SettingSwitchItem itemWithTitle:_dataSource[_index++]];
    
    //清除缓存
    SettingItem *clearCache = [SettingArrowItem itemWithTitle:_dataSource[_index++]];
    clearCache.option = ^{
        [self showAlert];
    };
    SettingGroup *group2 = [[SettingGroup alloc] init];
    group2.items = @[autoClear, clearCache];
    [self.groupArray addObject:group2];
    
}

- (void)setupGroup3
{
    //打赏
    SettingItem *support = [SettingArrowItem itemWithTitle:_dataSource[_index++]];
    support.option = ^{
        purchaseViewController *supportvc = [[purchaseViewController alloc] init];
        supportvc.title = @"鼓励一下开发者";
        supportvc.hidesBottomBarWhenPushed = YES;

        [self.navigationController pushViewController:supportvc animated:YES];
    };
    
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
        [self alertView:@"西贝阅读器"message:version cancel:@"OK"];
    };
    
    SettingGroup *group3 = [[SettingGroup alloc]init];
    group3.items = @[support, feedback, remark, about];
    [self.groupArray addObject:group3];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _groupArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    SettingGroup *group = _groupArray[section];
    if (section == 1) {
        if ([CBAppSettings sharedSettings].isPurchased) {
            if (![CBAppSettings sharedSettings].autoNightModeEnabled) {
                return group.items.count - 1;
            }
        } else {
            return group.items.count - 2;
        }
    }
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
    if ([item.title isEqualToString:@"清除缓存"]) {
        self.cacheLabel = cell.detailTextLabel;
        item.subtitle = [NSString stringWithFormat:@"%.2fMB", self.cacheSize];
    }
    if (!item.title) {
        self.nightModeTimeLabel = cell.detailTextLabel;
    }
    cell.item = item;
    if ([item.title isEqualToString:@"夜间模式"]) {
        UISwitch *switchView = (UISwitch *)cell.accessoryView;
        if ([CBAppSettings sharedSettings].autoNightModeEnabled) {
            switchView.enabled = NO;
        } 
    }
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


#pragma mark - SwitchControlDelegate

- (void)setState:(BOOL)isOn forSwitch:(NSString *)switchName
{
    switch ([_switchDic[switchName] intValue]) {
        case CBUpdateNotification:
            _settings.updateNotificationEnabled = isOn;
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
            [self reloadTableView];
            break;
            
        case CBFullScreenWhenScrolling:
            _settings.fullScreenEnabled = isOn;
            break;
            
        case CBNightMode:
            _settings.nightModeEnabled = isOn;
            break;
            
        case CBAutoNightMode:
            _settings.autoNightModeEnabled = isOn;
            [[NSNotificationCenter defaultCenter] postNotificationName:CBNightModeTimeIntervalChangedNotification object:nil];
            [self reloadTableView];
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
        case CBUpdateNotification:
            status = _settings.updateNotificationEnabled;
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
            
        case CBFullScreenWhenScrolling:
            status = _settings.fullScreenEnabled;
            break;
            
        case CBNightMode:
            status = _settings.nightModeEnabled;
            break;
            
        case CBAutoNightMode:
            status = _settings.autoNightModeEnabled;
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
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.nightModeTimeLabel = nil;
        [self.settingsTableView reloadData];
    });
}

#pragma mark - Actions
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
        CBObjectCache *objectCache = [CBObjectCache sharedCache];
        [objectCache clearDiskCache];
        _cacheSize = 0;
        [self.cacheLabel setText:@"0.00MB"];
//        [self.settingsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:[group.items indexOfObject:item] inSection:1], nil] withRowAnimation:UITableViewRowAnimationNone];
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
