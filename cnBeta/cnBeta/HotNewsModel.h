//
//  HotNewsModel.h
//  cnBeta
//
//  Created by hudy on 16/8/7.
//  Copyright © 2016年 hudy. All rights reserved.
//

/*
 
 aid = "teikaei ";
 bad = 0;
 catid = 24;
 collectnum = 0;
 comments = 179;
 counter = 132904;
 elite = 0;
 good = 121;
 hometext = "<p>8\U67082\U65e5\U6d88\U606f\Uff0c\U636e\U7f8e\U56fd\U79d1\U6280\U5a92\U4f53GeekWire\U62a5\U9053\Uff0c\U7f8e\U56fd\U534e\U76db\U987f\U5dde\U897f\U96c5\U56fe\U5e0211\U5c81\U5973\U5b69\U745e\U8d1d\U5361\Uff08Rebecca\Uff09\U548c9\U5c81\U59b9\U59b9\U91d1\U4f2f\U5229\U00b7\U6768\Uff08Kimberly Yeung\Uff09\Uff0c\U53bb\U5e74\U66fe\U5c06\U81ea\U5236\U7684\U98de\U884c\U5668\U9001\U4e0a23774\U7c73\U7684\U592a\U7a7a\U8fb9\U7f18\Uff0c\U4e3a\U6b64\U8fd8\U66fe\U53d7\U9080\U8bbf\U95ee\U767d\U5bab\U3002<strong>\U73b0\U5728\Uff0c\U8fd9\U5bf9\U59d0\U59b9\U81ea\U5236\U7684\U7b2c\U4e8c\U4e2a\U98de\U884c\U5668\U4e8e\U4e0a\U5468\U672b\U5347\U7a7a\Uff0c\U8fd9\U6b21\U5b83\U643a\U5e26\U4e86\U65b0\U7684\U4e58\U5ba2\Uff0c\U5347\U7a7a\U9ad8\U5ea6\U8d85\U8fc730884\U7c73\U3002</strong>\U745e\U8d1d\U5361\U548c\U91d1\U4f2f\U5229\U5236\U4f5c\U7684\U98de\U884c\U5668\U540d\U4e3aLoki Lego Launcher 2.0\Uff0c\U5e0c\U671b\U80fd\U591f\U5b9e\U73b0\U65b0\U7684\U76ee\U6807\Uff0c\U5e76\U6cbf\U9014\U6536\U96c6\U6709\U8da3\U7684\U79d1\U5b66\U6570\U636e\U3002</p>";
 ifcom = 1;
 inputtime = "2016-08-02 07:50:33";
 ishome = 1;
 keywords = "";
 listorder = 525503;
 mview = 1562;
 pollid = 0;
 queueid = 0;
 "rate_sum" = 2034;
 ratings = 1173;
 "ratings_story" = 861;
 score = 3902;
 "score_story" = 2433;
 sid = 525503;
 source = "\U7f51\U6613\U79d1\U6280@http://tech.163.com/";
 sourceid = 0;
 status = 1;
 style = "";
 thumb = "http://static.cnbetacdn.com/topics/b603e06ab9299d5.png";
 title = "\U7f8e\U56fd\U5c0f\U59d0\U59b9\U81ea\U5236\U98de\U884c\U5668\U4e8c\U6b21\U5347\U7a7a \U9ad8\U5ea6\U8d85\U8fc730884\U7c73";
 topic = 453;
 updatetime = 1470098617;
 "url_show" = "/articles/525503.htm";
 "user_id" = 0;
 
*/
#import <Foundation/Foundation.h>

@interface HotNewsModel : NSObject

@property (nonatomic, copy) NSString  *inputtime;
@property (nonatomic, copy) NSString  *title;
@property (nonatomic, copy) NSString  *sid;
@property (nonatomic, copy) NSString  *comments;
@property (nonatomic, copy) NSString  *thumb;
@property (nonatomic, copy) NSString  *counter;
@property (nonatomic, copy) NSString  *aid;


@end
