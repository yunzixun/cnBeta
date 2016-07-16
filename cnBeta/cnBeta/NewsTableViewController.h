//
//  NewsTableViewController.h
//  cnBeta
//
//  Created by hudy on 16/6/19.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"

@interface NewsTableViewController : UITableViewController
{
    sqlite3 *dataBase;
}

@end
