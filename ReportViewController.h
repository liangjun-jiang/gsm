//
//  ReportViewController.h
//  AccelerometerGraph
//
//  Created by Liangjun Jiang on 7/2/12.
//  Copyright (c) 2012 ByPass Lane. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ReportViewController;

@protocol ReportViewControllerDelegate
- (void)reportViewControllerDidFinish:(ReportViewController *)controller;
@end

@interface ReportViewController : UIViewController{
    
//    NSMutableArray *rawData;
}

@property (unsafe_unretained, nonatomic) id <ReportViewControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UITableView *mTableView;
@property (nonatomic, strong) NSMutableArray *rawData;

-(IBAction)done:(id)sender;
@end
