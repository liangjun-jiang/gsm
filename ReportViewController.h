//
//  ReportViewController.h
//  AccelerometerGraph
//
//  Created by Liangjun Jiang on 7/2/12.
//  Copyright (c) 2012 ByPass Lane. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EasyTracker.h"
@class ReportViewController;

@protocol ReportViewControllerDelegate
- (void)reportViewControllerDidFinish:(ReportViewController *)controller;
@end

@interface ReportViewController : TrackedUIViewController

@property (unsafe_unretained, nonatomic) id <ReportViewControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UITableView *mTableView;
@property (nonatomic, strong) NSMutableArray *rawData;
@property (nonatomic, strong) NSMutableArray *accelormeterData;
@property (nonatomic, strong) IBOutlet UINavigationBar *navBar;

-(IBAction)done:(id)sender;
-(IBAction)sendFeedback:(id)sender;
@end
