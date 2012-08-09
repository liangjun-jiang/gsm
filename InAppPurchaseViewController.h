//
//  RootViewController.h
//  InAppRage
//
//  Created by Ray Wenderlich on 2/28/11.
//  Copyright 2011 Ray Wenderlich. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EasyTracker.h"

@class InAppPurchaseViewController;

@protocol InAppPurchaseViewControllerDelegate
- (void)purchaseControllerDidFinish:(InAppPurchaseViewController *)controller;
@end

@interface InAppPurchaseViewController : TrackedUIViewController<UITableViewDataSource, UITableViewDelegate>

@property (unsafe_unretained, nonatomic) id <InAppPurchaseViewControllerDelegate> delegate;
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *mTable;


- (IBAction)done:(id)sender;



@end
