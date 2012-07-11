//
//  LJWebViewController.h
//  AccelerometerGraph
//
//  Created by Liangjun Jiang on 7/4/12.
//  Copyright (c) 2012 ByPass Lane. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EasyTracker.h"

@class LJWebViewController;

@protocol WebViewControllerDelegate
- (void)webViewControllerDidFinish:(LJWebViewController *)controller;
@end

@interface LJWebViewController : TrackedUIViewController


@property (nonatomic, strong) IBOutlet UIWebView *webView;
@property (unsafe_unretained, nonatomic) id <WebViewControllerDelegate> delegate;

@end
