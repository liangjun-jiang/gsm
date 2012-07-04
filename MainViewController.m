

#import "MainViewController.h"
#import "GraphView.h"
#import "AccelerometerFilter.h"
#import <CoreMotion/CoreMotion.h>

#define kUpdateFrequency	60.0
#define kLocalizedPause		NSLocalizedString(@"Paused","pause taking samples")
#define kLocalizedResume	NSLocalizedString(@"Resumed","resume taking samples")

@interface MainViewController(){
    NSMutableArray *rawDataArray;
    CMMotionManager *motionManager;

}
@property (nonatomic) NSMutableArray *rawDataArray;
@property (nonatomic, strong) CMMotionManager *motionManager;

// Sets up a new filter. Since the filter's class matters and not a particular instance
// we just pass in the class and -changeFilter: will setup the proper filter.
-(void)changeFilter:(Class)filterClass;

@end

@implementation MainViewController

@synthesize unfiltered, filtered, pause, filterLabel;
@synthesize rawDataArray;
@synthesize motionManager;

- (void)flipsideViewControllerDidFinish:(LJFlipsideViewController *)controller
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)reportViewControllerDidFinish:(ReportViewController *)controller
{
    [self dismissModalViewControllerAnimated:YES];
    
}

- (void)webViewControllerDidFinish:(LJWebViewController *)controller
{
    [self dismissModalViewControllerAnimated:YES];
    
}

- (void)discloseSetting:(id)sender
{
    LJFlipsideViewController *ljfvc = [[LJFlipsideViewController alloc] initWithNibName:@"LJFlipsideViewController" bundle:nil];
    ljfvc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    ljfvc.delegate = self;
    [self presentModalViewController:ljfvc animated:YES];
}

- (void)discloseInfo:(id)sender
{
//    LJWebViewController *web = [[LJWebViewController alloc] initWithNibName:@"LJWebViewController" bundle:nil];
//    web.delegate = self;
//    [self presentModalViewController:web animated:YES];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

// Implement viewDidLoad to do additional setup after loading the view.
-(void)viewDidLoad
{
	[super viewDidLoad];
    
    
  	pause.possibleTitles = [NSSet setWithObjects:kLocalizedPause, kLocalizedResume, nil];
  	isPaused = YES;
	useAdaptive = NO;
	[self changeFilter:[LowpassFilter class]];

    motionManager = [[CMMotionManager alloc] init];
    
    motionManager.deviceMotionUpdateInterval = 1.0/kUpdateFrequency;
    
    if (motionManager.deviceMotionAvailable) {
        [motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion *motion, NSError *error){
            [self performSelector:@selector(performLogDeviceMotion:) onThread:[NSThread mainThread] withObject:motion waitUntilDone:YES];
            
        }];
    } else {
        NSLog(@"Device Motion is not available!");
        motionManager = nil;
    }
	
	[unfiltered setIsAccessibilityElement:YES];
	[unfiltered setAccessibilityLabel:NSLocalizedString(@"unfilteredGraph", @"")];

	[filtered setIsAccessibilityElement:YES];
	[filtered setAccessibilityLabel:NSLocalizedString(@"filteredGraph", @"")];
    
    rawDataArray = [NSMutableArray array];
    
}

-(void)viewDidUnload
{
	[super viewDidUnload];
	self.unfiltered = nil;
	self.filtered = nil;
	self.pause = nil;
	self.filterLabel = nil;
    self.rawDataArray = nil;
    self.motionManager = nil;
}

// UIAccelerometerDelegate method, called when the device accelerates.
//-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
//{
//	// Update the accelerometer graph view
//	if(!isPaused)
//	{
//		[filter addAcceleration:acceleration];
//        
//		[unfiltered addX:acceleration.x y:acceleration.y z:acceleration.z];
//		[filtered addX:filter.x y:filter.y z:filter.z];
//	}
//}

-(void)changeFilter:(Class)filterClass
{
	// Ensure that the new filter class is different from the current one...
	if(filterClass != [filter class])
	{
		// And if it is, release the old one and create a new one.
		filter = [[filterClass alloc] initWithSampleRate:kUpdateFrequency cutoffFrequency:5.0];
		// Set the adaptive flag
		filter.adaptive = useAdaptive;
		// And update the filterLabel with the new filter name.
		filterLabel.text = filter.name;
	}
}

-(IBAction)pauseOrResume:(id)sender
{
	if(isPaused)
	{
		// If we're paused, then resume and set the title to "Pause"
		isPaused = NO;
		pause.title = kLocalizedPause;
        
        // We show the report immediately
        [motionManager stopDeviceMotionUpdates];
        ReportViewController *rvc = [[ReportViewController alloc] initWithNibName:@"ReportViewController" bundle:nil];
        rvc.delegate = self;
        rvc.rawData = rawDataArray;
        [self presentModalViewController:rvc animated:YES];
	}
	else
	{
		// If we are not paused, then pause and set the title to "Resume"
		isPaused = YES;
		pause.title = kLocalizedResume;
        if ([self.rawDataArray count] > 0) {
            [self.rawDataArray removeAllObjects];
        }
        
        // We start the motionManager
        if (motionManager.deviceMotionAvailable) {
            [motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion *motion, NSError *error){
                [self performSelector:@selector(performLogDeviceMotion:) onThread:[NSThread mainThread] withObject:motion waitUntilDone:YES];
                
            }]; 
        } else {
            NSLog(@"Device Motion is not available!");
            motionManager = nil;
        }

            
	}
	
}

-(IBAction)filterSelect:(id)sender
{
	if([sender selectedSegmentIndex] == 0)
	{
		// Index 0 of the segment selects the lowpass filter
		[self changeFilter:[LowpassFilter class]];
	}
	else
	{
		// Index 1 of the segment selects the highpass filter
		[self changeFilter:[HighpassFilter class]];
	}

	// Inform accessibility clients that the filter has changed.
	UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
}

-(IBAction)adaptiveSelect:(id)sender
{
	// Index 1 is to use the adaptive filter, so if selected then set useAdaptive appropriately
	useAdaptive = [sender selectedSegmentIndex] == 1;
	// and update our filter and filterLabel
	filter.adaptive = useAdaptive;
	filterLabel.text = filter.name;
	
	// Inform accessibility clients that the adaptive selection has changed.
	UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
}



- (void)performLogDeviceMotion: (CMDeviceMotion *)motion{
    
    // Refer to: http://en.wikipedia.org/wiki/File:Rollpitchyawplain.png
    CMRotationRate rotationRate = motion.rotationRate;
    
    float fx = rotationRate.x*MULTIPLIER;
    float fy = rotationRate.y*MULTIPLIER;
    float fz = rotationRate.z*MULTIPLIER;
  
    // Let's just count one max value 
    if (fy > 0) {
        [rawDataArray addObject:[NSNumber numberWithFloat:sqrt(fx*fx + fy*fy + fz*fz)]];
    }
    
    [unfiltered addRotationX:fx y:fy z:fz];

    [filtered addRotationX:fx y:fy z:fz];
    
}




@end
