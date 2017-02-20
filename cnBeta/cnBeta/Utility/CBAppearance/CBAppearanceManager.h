//
//  CBAppearanceManager.h
//  cnBeta
//
//  Created by hudy on 16/8/26.
//  Copyright © 2016年 hudy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CBAppearanceManager : NSObject

@property (nonatomic, readonly)UIFont *CBFont;
@property (nonatomic, readonly)UIFont *CBCommentFont;

+ (instancetype)sharedManager;

- (void)setup;

- (void)updateCBFont;

@end
