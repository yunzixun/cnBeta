//
//  DYAppearanceManager.h
//  cnBeta
//
//  Created by hudy on 16/8/26.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DYAppearanceManager : NSObject

@property (nonatomic, readonly)UIFont *CBFont;

+ (instancetype)sharedManager;

- (void)setup;

- (void)updateCBFont;

@end
