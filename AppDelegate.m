
#import "AppDelegate.h"
#import "MainViewController.h"
#import "InAPPIAPHelper.h"
#import "EasyTracker.h"

@implementation AppDelegate

@synthesize window, viewController;

-(void)applicationDidFinishLaunching:(UIApplication*)application
{
	[window addSubview:viewController.view];
}


- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [EasyTracker launchWithOptions:launchOptions
                    withParameters:nil
                         withError:nil];
    
    return YES;
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:[InAPPIAPHelper sharedHelper]];
}

@end
