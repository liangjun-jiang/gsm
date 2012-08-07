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

- (void)requestProducts{
       
    self.request = [[SKProductsRequest alloc] initWithProductIdentifiers:_produtIdentifiers];
    _request.delegate = self;
    [_request start];
}

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers
{
    if ((self = [super init])) {
        _produtIdentifiers = productIdentifiers;
    }
    
    // Check for Previous Purchased products
    NSMutableSet *purchasedProducts = [NSMutableSet set];
    [_produtIdentifiers enumerateObjectsUsingBlock:^(id obj, BOOL *stop){
        BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:obj];
        
        if (productPurchased) {
            [purchasedProducts addObject:obj];
            NSLog(@"purchased: %@",obj);
        }
        
        NSLog(@"not purchased: %@",obj);
    }];
    
    
    self.purchasedProducts = purchasedProducts;
    
    return self;
}


- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    
    self.products = response.products;
    self.request = nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kProductsLoadedNotification object:_products];
    
}
@end
