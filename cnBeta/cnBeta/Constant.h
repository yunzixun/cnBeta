//
//  Constant.h
//  cnBeta
//
//  Created by hudy on 16/7/15.
//  Copyright © 2016年 hudy. All rights reserved.
//
#define cnBeta_APP_ID               @"1133433243"
#define cnBeta_APP_STORE_URL        @"https://itunes.apple.com/cn/app/id"cnBeta_APP_ID"?mt=8"
#define cnBeta_APP_STORE_REVIEW_URL @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id="cnBeta_APP_ID@"&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software"


#define  cb_redColor            [UIColor colorWithRed:255./255. green:41./255. blue:101./255. alpha:1]
#define  HostColor              [UIColor lightGrayColor]
#define  FloorColor             [UIColor lightGrayColor]
#define  LayoutBackgroundColor  [UIColor colorWithRed:251./255. green:249./255. blue:238./255. alpha:1]
#define  LayoutBordColor        [UIColor colorWithRed:215./255. green:215./255. blue:191./255. alpha:1]
#define  rectangleBorderColor   [UIColor colorWithRed:60./255.  green:165./255. blue:255./255. alpha:1]
#define  cmtHeaderColor         [UIColor colorWithRed:52./255.  green:158./255. blue:245./255. alpha:1]
#define  cmtNameColor           [UIColor colorWithRed:60./255.  green:165./255. blue:255./255. alpha:1]
#define  globalColor            [UIColor colorWithRed:60/255.0  green:165/255.0 blue:255/255.0 alpha:1.0]



#define  LayoutBordWidth        .6
#define  rectangleBordWidth     1.0


#define  NameFont        [[CBAppearanceManager sharedManager].CBFont fontWithSize:14]
#define  HostFont        [[CBAppearanceManager sharedManager].CBFont fontWithSize:11]
#define  FloorFont       [[CBAppearanceManager sharedManager].CBFont fontWithSize:10]
#define  CommentFont     [CBAppearanceManager sharedManager].CBCommentFont


#define NavTabBarFont    [[CBAppearanceManager sharedManager].CBFont fontWithSize:15]
#define NewsTitleFont    [[CBAppearanceManager sharedManager].CBFont fontWithSize:15]
#define PadNewsTitleFont [[CBAppearanceManager sharedManager].CBFont fontWithSize:20]

#define NewsTimeFont     [[CBAppearanceManager sharedManager].CBFont fontWithSize:11]
#define PadNewsTimeFont  [[CBAppearanceManager sharedManager].CBFont fontWithSize:13]

#define CmtNumFont       [[CBAppearanceManager sharedManager].CBFont fontWithSize:10]
#define PadCmtNumFont    [[CBAppearanceManager sharedManager].CBFont fontWithSize:12]

#define cmtTitle         [[CBAppearanceManager sharedManager].CBFont fontWithSize:13]
#define segControlFont   [[CBAppearanceManager sharedManager].CBFont fontWithSize:15]


#define ScreenWidth   [UIScreen mainScreen].bounds.size.width
#define ScreenHeight  [UIScreen mainScreen].bounds.size.height
#define MaxOverlapNumber 6
#define OverlapSpace 3

#define startTimeKey  @"startTime"
#define endTimeKey    @"endTime"

#define isPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) 
