//
//  IAPHelper.h
//  GolfSwingMeter
//
//  Created by Liangjun Jiang on 7/20/12.
//  Copyright (c) 2012 ByPass Lane. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StoreKit/StoreKit.h"

#define kProductsLoadedNotification        @"ProductsLoaded"

// Add two new notifications
#define kProductPurchasedNotification       @"ProductPurchased"
#define kProductPurchaseFailedNotification  @"ProductPurchaseFailed"

@interface IAPHelper : NSObject<SKProductsRequestDelegate, SKPaymentTransactionObserver>{
    NSSet *_produtIdentifiers;
    NSArray *_products;
    NSMutableSet *_purchasedProducts;
    SKProductsRequest *_request;
    
}

@property (retain) NSSet *productIdentifier;
@property (retain) NSArray *products;
@property (retain) NSMutableSet *purchasedProducts;
@property (retain) SKProductsRequest *request;

- (void)requestProducts;
- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)buyProductIdentifier:(NSString *)productIdentifier;
@end
