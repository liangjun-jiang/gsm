//
//  LJWebViewController.m
//  AccelerometerGraph
//
//  Created by Liangjun Jiang on 7/4/12.
//  Copyright (c) 2012 ByPass Lane. All rights reserved.
//

#import "LJWebViewController.h"
#import "SVProgressHUD.h"
//#define URL_STRING  @"http://ljsportapps.com/sm/index.html"
#define URL_STRING @"http://google.com"

@interface LJWebViewController ()<UIWebViewDelegate>

@end

@implementation LJWebViewController
@synthesize webView = _webView, delegate = _delegate;

- (IBAction)done:(id)sender
{
    [self.delegate webViewControllerDidFinish:self];
    
}


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
    NSURL *url = [NSURL URLWithString:URL_STRING];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.webView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Delegate Methods
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Loading...", @"Loading...") maskType:SVProgressHUDMaskTypeGradient];
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [SVProgressHUD dismiss];
    
}


@end
