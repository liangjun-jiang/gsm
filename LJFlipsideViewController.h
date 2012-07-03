//
//  LJFlipsideViewController.h
//  SwingTracker
//
//  Created by Liangjun Jiang on 6/20/12.
//  Copyright (c) 2012 ByPass Lane. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LJFlipsideViewController;

@protocol LJFlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(LJFlipsideViewController *)controller;
@end

@interface LJFlipsideViewController : UITableViewController

@property (assign, nonatomic) id <LJFlipsideViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;

@end
