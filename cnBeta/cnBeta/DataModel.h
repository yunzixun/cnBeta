//
//  DataModel.h
//  cnBeta
//
//  Created by hudy on 16/7/3.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 aid = raymon725;
 bad = 0;
 catid = 7;
 collectnum = 0;
 comments = 0;
 counter = 0;
 elite = 0;
 good = 0;
 hometext = "<p><strong>\U636e\U5916\U5a92\U62a5\U9053\Uff0c\U53c8\U6709\U4e09\U5bb6\U5f8b\U5e08\U4e8b\U52a1\U6240\U52a0\U5165\U4e86\U4eca\U5e748\U6708\U4efd\U53d1\U8d77\U7684\U9488\U5bf9\U82f9\U679c\U7684\U8bc9\U8bbc\Uff0c\U539f\U544a\U65b9\U9762\U6307\U8d23\U8be5\U516c\U53f8\U672a\U80fd\U610f\U8bc6\U5230\U90e8\U5206iPhone 6\U548c6 Plus\U7528\U6237\U9047\U5230\U7684\U89e6\U63a7\U6545\U969c\U95ee\U9898\U6216\U8fdb\U884c\U514d\U8d39\U4fee\U590d\U3002</strong>\U5f8b\U5e08Richard McCune\U5728\U63a5\U53d7Motherboard\U91c7\U8bbf\U65f6\U8868\U793a\U6709\U51e0\U540d\U65b0\U539f\U544a\U7684\U52a0\U5165\Uff0c\U6709\U8fd1\U4e07\U4eba\U8054\U7cfb\U4e86\U8be5\U5f8b\U6240\Uff0c\U79f0\U5176\U5e0c\U671b\U53c2\U4e0e\U76ee\U524d\U6b63\U5728\U7f8e\U56fd\U52a0\U5dde\U5317\U533a\U5730\U65b9\U6cd5\U9662\U7684\U8bc9\U8bbc\U3002<br/></p>";
 ifcom = 1;
 inputtime = "2016-10-10 11:34:04";
 ishome = 1;
 keywords = "";
 listorder = 546617;
 mview = 0;
 pollid = 0;
 queueid = 0;
 "rate_sum" = 0;
 ratings = 0;
 "ratings_story" = 0;
 score = 0;
 "score_story" = 0;
 sid = 546617;
 source = "cnBeta.COM";
 sourceid = 1;
 status = 1;
 style = "";
 thumb = "http://static.cnbetacdn.com/article/2016/1010/be82a4083dd0a9ff4bca247b7ed141d1.gif_100x100.gif";
 title = "\U53c8\U6709\U4e09\U5bb6\U5f8b\U6240\U52a0\U5165\U4e86\U9488\U5bf9iPhone 6\U89e6\U63a7\U6545\U969c\U7684\U96c6\U4f53\U8bc9\U8bbc";
 topic = 379;
 updatetime = 0;
 "url_show" = "/articles/546617.htm";
 "user_id" = 0;
*/
@interface DataModel : NSObject<NSCoding>

@property (nonatomic, copy)NSString *title;
@property (nonatomic, copy)NSString *inputtime;
@property (nonatomic, copy)NSString *sid;
@property (nonatomic, copy)NSString *counter;
@property (nonatomic, copy)NSString *comments;
@property (nonatomic, copy)NSString *thumb;
@property (nonatomic, copy)NSString *aid;

@end
