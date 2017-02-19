//
//  supportViewController.h
//  cnBeta
//
//  Created by hudy on 2017/1/18.
//  Copyright © 2017年 hudy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>


@interface purchaseViewController : UIViewController<SKPaymentTransactionObserver,SKProductsRequestDelegate>



@end
