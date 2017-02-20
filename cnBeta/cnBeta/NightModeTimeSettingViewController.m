//
//  NightModeTimeSettingViewController.m
//  cnBeta
//
//  Created by hudy on 2017/1/13.
//  Copyright © 2017年 hudy. All rights reserved.
//

#import "NightModeTimeSettingViewController.h"
#import "CBAppearanceManager.h"
#import "CBAppSettings.h"

extern NSString *const CBNightModeTimeIntervalChangedNotification;

@interface NightModeTimeSettingViewController ()
//@property (nonatomic, assign)
@property (weak, nonatomic) IBOutlet UISegmentedControl *timeIntervalControl;
@property (strong, nonatomic) UIDatePicker *timePicker;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSString *startTime;
@property (nonatomic, strong) NSString *endTime;

@end

@implementation NightModeTimeSettingViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"HH:mm";
    }
    return _dateFormatter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.startTime = [[NSUserDefaults standardUserDefaults] stringForKey:startTimeKey];
    self.endTime = [[NSUserDefaults standardUserDefaults] stringForKey:endTimeKey];
    self.timeIntervalControl.tintColor = globalColor;
    [self.timeIntervalControl setTitle:[NSString stringWithFormat:@"从%@", self.startTime] forSegmentAtIndex:0];
    [self.timeIntervalControl setTitle:[NSString stringWithFormat:@"至%@", self.endTime] forSegmentAtIndex:1];
    [self.timeIntervalControl setTitleTextAttributes:@{NSFontAttributeName:segControlFont} forState:UIControlStateNormal];
    self.timeIntervalControl.selectedSegmentIndex = 0;
    [self.timeIntervalControl addTarget:self action:@selector(timeSegmentedControlSwitched:) forControlEvents:UIControlEventValueChanged];

    self.timePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 300, ScreenWidth, 160)];
    self.timePicker.datePickerMode = UIDatePickerModeTime;
    self.timePicker.date = [self.dateFormatter dateFromString:self.startTime];
    [self.timePicker addTarget:self action:@selector(timePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.timePicker];
    [self configBackground];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(configBackground) name:CBAppSettingThemeChangedNotification object:nil];
}

- (void)configBackground
{
    self.view.backgroundColor = [CBAppSettings sharedSettings].isNightMode ? [UIColor darkGrayColor] : [UIColor whiteColor];
}

- (void)timeSegmentedControlSwitched:(id)sender
{
    self.timePicker.date = [self.dateFormatter dateFromString:self.timeIntervalControl.selectedSegmentIndex ? self.endTime : self.startTime];
}


- (void)timePickerValueChanged:(id)sender
{
    if (self.timeIntervalControl.selectedSegmentIndex == 0) {
        self.startTime = [self.dateFormatter stringFromDate:self.timePicker.date];
        [[NSUserDefaults standardUserDefaults] setObject:self.startTime forKey:startTimeKey];
        [self.timeIntervalControl setTitle:[NSString stringWithFormat:@"从%@", self.startTime] forSegmentAtIndex:0];
    } else {
        self.endTime = [self.dateFormatter stringFromDate:self.timePicker.date];
        [[NSUserDefaults standardUserDefaults] setObject:self.endTime forKey:endTimeKey];
        [self.timeIntervalControl setTitle:[NSString stringWithFormat:@"至%@", self.endTime] forSegmentAtIndex:1];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:CBNightModeTimeIntervalChangedNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
