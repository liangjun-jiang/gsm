//
//  IAPHelper.m
//  GolfSwingMeter
//
//  Created by Liangjun Jiang on 7/20/12.
//  Copyright (c) 2012 ByPass Lane. All rights reserved.
//

#import "IAPHelper.h"

@implementation IAPHelper
@synthesize productIdentifier = _produtIdentifiers;
@synthesize products = _products;
@synthesize purchasedProducts = _purchasedProducts;
@synthesize request = _request;

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers
{
    if ((self = [super init])) {
        _produtIdentifiers = productIdentifiers;
        
        // Check for Previous Purchased products
        NSMutableSet *purchasedProducts = [NSMutableSet set];
        [_produtIdentifiers enumerateObjectsUsingBlock:^(id obj, BOOL *stop){
            BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:obj];
            
            if (productPurchased) {
                [purchasedProducts addObject:obj];
                DebugLog(@"purchased: %@",obj);
            }
            
            DebugLog(@"not purchased: %@",obj);
        }];
        
        self.purchasedProducts = purchasedProducts;
    }
    
    return self;
}

- (void)requestProducts{
       
    self.request = [[SKProductsRequest alloc] initWithProductIdentifiers:_produtIdentifiers];
    _request.delegate = self;
    [_request start];
}




- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    
    self.products = response.products;
    self.request = nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kProductsLoadedNotification object:_products];
    
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    
    DebugLog(@"what's the error :%@",error.localizedDescription);
    
}

- (void)buyProductIdentifier:(NSString *)productIdentifier {
    DebugLog(@"Buying %@...", productIdentifier);

    SKPayment *payment = [SKPayment paymentWithProductIdentifier:productIdentifier];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
}

# pragma mark - delegate methods
- (void)recordTransaction:(SKPaymentTransaction *)transaction {
    // Optional: Record the transaction on the server side...
}

- (void)provideContent: (NSString *)productIdentifier {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [_purchasedProducts addObject:productIdentifier];
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction{
    DebugLog(@"Complete transaction");
    [self recordTransaction:transaction];
    [self provideContent:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    DebugLog(@"restore transaction");
    [self recordTransaction:transaction];
    [self provideContent:transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    if (transaction.error.code != SKErrorPaymentCancelled) {
        DebugLog(@"Transaction error: %@",transaction.error.localizedDescription);
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kProductPurchaseFailedNotification object:transaction];
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    [transactions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        SKPaymentTransaction *transaction = (SKPaymentTransaction *)obj;
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            default:
                break;
        }
        
    }];
}



@end
