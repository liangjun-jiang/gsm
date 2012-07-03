
#import "AppDelegate.h"
#import "MainViewController.h"

@implementation AppDelegate

@synthesize window, viewController;

-(void)applicationDidFinishLaunching:(UIApplication*)application
{
	// Add the view controller's view to the window
    
//    viewController = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
//    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    
	[window addSubview:viewController.view];
//    [window addSubview:navController.view];
}

// Release resources.

@end
