
#import "AppDelegate.h"
#import "MainViewController.h"

@implementation AppDelegate

@synthesize window, viewController, instructionViewController;

-(void)applicationDidFinishLaunching:(UIApplication*)application
{
    
	[window addSubview:viewController.view];
}



@end
