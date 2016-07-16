//
//  DataModel.h
//  cnBeta
//
//  Created by hudy on 16/7/3.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 "id": "516363",
 "title": "玩家滥用《守望先锋》源氏漏洞 暴雪一怒永封",
 "videos": [],
 "pageFrom": "网易游戏",
 "pageDate": "2016-07-03T12:21:56.000Z",
 "app_view_num": 74,
 "view_num": 74,
 "parsedTime": "2小时前",
 "timestamp": 1467548516000,
 "images": [],
 "summary": "随着竞技模式的上线玩家社区再次沸腾起来，但也带来不好的一面，在胜负心的驱使下，一些不良玩家利用各种办法来谋求比赛的胜利或者避免失败。近日玩家社区就曝光了一个利用源氏爬墙致使服务器崩溃的严重漏洞，该漏洞触发后会使得比赛内的所有的玩家返回游戏菜单并且不会有竞技排名变化，正如正常的服务器错误一样。"
*/
@interface DataModel : NSObject<NSCoding>

@property (nonatomic, copy)NSString *title;
@property (nonatomic, copy)NSString *pubtime;
@property (nonatomic, copy)NSString *sid;
@property (nonatomic, copy)NSString *counter;
@property (nonatomic, copy)NSString *comments;
@property (nonatomic, copy) NSString *thumb;

@end
