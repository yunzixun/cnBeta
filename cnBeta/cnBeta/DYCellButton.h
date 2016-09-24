//
//  DYCellButton.h
//  cnBeta
//
//  Created by hudy on 16/9/15.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DYCellButton : UIButton

@property (nonatomic, strong)NSIndexPath *indexPath;
@property (nonatomic, strong)id commentInfo;

@end
