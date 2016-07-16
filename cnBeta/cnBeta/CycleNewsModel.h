//
//  CycleNewsModel.h
//  cnBeta
//
//  Created by hudy on 16/7/4.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CycleNewsModel : NSObject

@property (nonatomic, copy)NSString *id;
@property (nonatomic, copy)NSString *title;
@property (nonatomic, strong)NSArray *images;

@end
