//
//  InAPPIAPHelper.m
//  GolfSwingMeter
//
//  Created by LIANGJUN JIANG on 8/7/12.
//
//

#import "InAPPIAPHelper.h"

@implementation InAPPIAPHelper

static InAPPIAPHelper *_sharedHelper;

+ (InAPPIAPHelper *)sharedHelper {
    if (_sharedHelper != nil) {
        return _sharedHelper;
    }
    _sharedHelper = [[InAPPIAPHelper alloc] init];
    
    return _sharedHelper;
}

- (id)init {
    
    NSSet *productIdentifier = [NSSet setWithObjects:@"com.ljsportapps.GolfSwingMeter.report",@"com.ljsportapps.GolfSwingMeter.realtimefeedback", nil];
    
    self = [super initWithProductIdentifiers:productIdentifier];
    if (self) {
        
    }
    
    return self;
}

@end
