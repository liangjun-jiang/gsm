//
//  LJWebViewController.m
//  AccelerometerGraph
//
//  Created by Liangjun Jiang on 7/4/12.
//  Copyright (c) 2012 ByPass Lane. All rights reserved.
//

#import "LJWebViewController.h"

@interface LJWebViewController ()<UIWebViewDelegate>

@end

@implementation LJWebViewController
@synthesize webView = _webView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Delegate Methods
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
    
}


@end
