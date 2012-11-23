

#import "MainViewController.h"
#import "GraphView.h"
#import <iAd/iAd.h>
#import "AccelerometerFilter.h"
#import <CoreMotion/CoreMotion.h>
#import "LJFlipsideViewController.h"
#import "ReportViewController.h"
#import "LJWebViewController.h"
#import "IAPHelper.h"
#import "InAPPIAPHelper.h"
#import "Reachability.h"
#import "SVProgressHUD/SVProgressHUD.h"
#import "InAppPurchaseViewController.h"

#define kUpdateFrequency	60.0
#define kLocalizedPause		NSLocalizedString(@"Paused","pause taking samples")
#define kLocalizedResume	NSLocalizedString(@"Resumed","resume taking samples")

#define DRIVER_LENGTH 44.0

#define FITTING_FACTOR 8 //mph

#define GRAVITY_ACCELERATION 9.8  //m*s^-2


#define  NOISE_FLOOR   0.1 

#define REPORT_IDENTIFIER @"com.ljsportapps.GolfSwingMeter.report"
#define REALTIME_IDENTIFIER @"com.ljsportapps.GolfSwingMeter.realtimefeedback"

@interface MainViewController()<UIScrollViewDelegate,LJFlipsideViewControllerDelegate, ReportViewControllerDelegate, WebViewControllerDelegate,ADBannerViewDelegate>{
    NSMutableArray *rawDataArray;
    CMMotionManager *motionManager;
    
    BOOL pageControlBeingUsed;
    
    UIPageControl *pageControl;
    
    UIScrollView *scrollView;
    
    NSMutableArray *accelometerData;
    
    float velocity;
    
    
}
@property (nonatomic, strong) NSMutableArray *rawDataArray;
@property (nonatomic, strong) NSMutableArray *accelometerData;
@property (nonatomic, strong) NSMutableArray *velocityArray;

@property (nonatomic, strong) ADBannerView *bannerView;

@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIScrollView *scrollView;

@property(nonatomic, retain) LJFlipsideViewController *ljfvc;
@property(nonatomic, retain) ReportViewController *rvc;
@property(nonatomic, retain) LJWebViewController *web;
@property (nonatomic, retain) InAppPurchaseViewController *inAppViewController;


// Sets up a new filter. Since the filter's class matters and not a particular instance
// we just pass in the class and -changeFilter: will setup the proper filter.
//-(void)changeFilter:(Class)filterClass;

@end

@implementation MainViewController

@synthesize unfiltered, filtered, pause, filterLabel;
@synthesize rawDataArray;
@synthesize motionManager;
@synthesize velocityArray;
@synthesize pageControl, scrollView;
@synthesize ljfvc, web, rvc, inAppViewController;
@synthesize accelometerData;
@synthesize bannerView;


#pragma mark - delegate method
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

//- (void)purchaseControllerDidFinish:(InAppPurchaseViewController *)controller
//{
//    [self dismissModalViewControllerAnimated:YES];
//}


#pragma mark - button Item methods

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
		filterLabel.text = @"Swing Tempo";//[NSString stringWithFormat:@"Accelerometer + %@",filter.name];
	}
}


-(IBAction)pauseOrResume:(id)sender
{
    // we set it to 0 otherwise the data will keep accumulatin
    
    velocity = 0.0;
	if(isPaused)
	{
		// If we're paused, then resume and set the title to "Pause"
		isPaused = NO;
		pause.title = kLocalizedPause;
        
        // We show the report immediately
        [motionManager stopDeviceMotionUpdates];
        
        [self discloseReport];
//        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//        if ([defaults boolForKey:REPORT_IDENTIFIER]) {
//            [self discloseReport];
//        } else
//            [self loadingInAppPurchaseItems];
	}
	else
	{
		// If we are not paused, then pause and set the title to "Resume"
		isPaused = YES;
		pause.title = kLocalizedResume;
        if ([self.rawDataArray count] > 0) {
            [self.rawDataArray removeAllObjects];
        }
        
        if ([accelometerData count] > 0){
            [accelometerData removeAllObjects];
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

- (void)performLogDeviceMotion: (CMDeviceMotion *)motion{
    
    // Refer to: http://en.wikipedia.org/wiki/File:Rollpitchyawplain.png
    CMRotationRate rotationRate = motion.rotationRate;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    float length = 0.0;
    if ([defaults objectForKey:CLUB]) {
        length = [[[defaults objectForKey:CLUB] objectForKey:@"length"] floatValue];
    } else {
        length = DRIVER_LENGTH;
    }
    
    float fitting_param = [[[defaults objectForKey:CLUB] objectForKey:@"fitting_param"] floatValue];
    
    float fx = rotationRate.x*length*INCH_TO_M*METER_TO_MILE;
    float fy = rotationRate.y*length*INCH_TO_M*METER_TO_MILE;
    float fz = rotationRate.z*length*INCH_TO_M*METER_TO_MILE;
    
    // Let's just count one max value
    // Gyroscope gives the different direction value for clockwise & anti-clockwise rotation
    if ([defaults objectForKey:HANDED]) {
        if ([[defaults objectForKey:HANDED] isEqualToString:@"Right-handed"]) {
            if (fy > 0) {
                [rawDataArray addObject:[NSNumber numberWithFloat:sqrt(fx*fx + fy*fy + fz*fz) + fitting_param]];
            }
        } else if ([[defaults objectForKey:HANDED] isEqualToString:@"Left-handed"]){
            if (fy < 0) {
                [rawDataArray addObject:[NSNumber numberWithFloat:sqrt(fx*fx + fy*fy + fz*fz)+ fitting_param]];
            }
        }
    }
    else {
        if (fy > 0) {
            [rawDataArray addObject:[NSNumber numberWithFloat:sqrt(fx*fx + fy*fy + fz*fz)+ fitting_param]];
        }
    }
    [unfiltered addRotationX:fx y:fy z:fz];
    
    // We integral the measured accerelation to get the velocity difference ( f(t1)
    // x - red, y - green, z - blue
    float x, y,z;
    x = motion.userAcceleration.x;
    y = motion.userAcceleration.y;
    z = motion.userAcceleration.z;
    
    [accelometerData addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:x], @"accX",[NSNumber numberWithFloat:y], @"accY",[NSNumber numberWithFloat:z], @"accZ", nil]];
    
    //for right-handed, backswing starts from x increase postively then reach peak
    //at the top, x = 0;, then x < 0, at the impack, x reaches peack
    // then x decreases.
    
    velocity = 0.0;
    
    if (fabs(x) > NOISE_FLOOR) {
        float r = x*GRAVITY_ACCELERATION;
        
        [velocityArray addObject:[NSNumber numberWithFloat:r]];
        for (int i = 0; i< [velocityArray count]; i++) {
            velocity +=[[velocityArray objectAtIndex:i] floatValue] * 1/kUpdateFrequency;
        }
    }
    
    [filtered addX:velocity y:velocity z:velocity];
    
}

//- (void)loadingInAppPurchaseItems{
//    inAppViewController = [[InAppPurchaseViewController alloc] initWithNibName:@"InAppPurchaseViewController" bundle:nil];
//    inAppViewController.delegate = self;
//    [self presentModalViewController:inAppViewController animated:YES];
//}

- (void)discloseReport
{
    rvc = [[ReportViewController alloc] initWithNibName:@"ReportViewController" bundle:nil];
    rvc.delegate = self;
    rvc.rawData = rawDataArray;
    rvc.accelormeterData = accelometerData;
    [self presentModalViewController:rvc animated:YES];
}

- (void)discloseSetting:(id)sender
{
    ljfvc = [[LJFlipsideViewController alloc] initWithNibName:@"LJFlipsideViewController" bundle:nil];
    ljfvc.delegate = self;
    [self presentModalViewController:ljfvc animated:YES];
}

- (void)discloseInfo:(id)sender
{
    web = [[LJWebViewController alloc] initWithNibName:@"LJWebViewController" bundle:nil];
    web.delegate = self;
    web.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:web animated:YES];
    
}

#pragma mark view cycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:kProductPurchasedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchaseFailed:) name:kProductPurchaseFailedNotification object:nil];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey:@"PURCHASED"]) {
        NSLog(@"ads");
        self.bannerView = [[ADBannerView alloc] initWithFrame:CGRectMake(0.0, 336.0, self.view.frame.size.width, 44.0)];
        self.bannerView.delegate = self;
    }
    
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
//        NSLog(@"Device Motion is not available!");
        motionManager = nil;
    }
	
	[unfiltered setIsAccessibilityElement:YES];
	[unfiltered setAccessibilityLabel:NSLocalizedString(@"unfilteredGraph", @"")];

	[filtered setIsAccessibilityElement:YES];
	[filtered setAccessibilityLabel:NSLocalizedString(@"filteredGraph", @"")];
    
    rawDataArray = [NSMutableArray array];
    accelometerData = [NSMutableArray array];
    
    velocityArray = [NSMutableArray array];
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey:@"ShowGuide"]) {
        [self setUpInstructionGuide];
    } 
    [defaults setBool:YES forKey:@"ShowGuide"];
    [defaults synchronize];
}

-(void)viewDidUnload
{
	[super viewDidUnload];
	self.unfiltered = nil;
	self.filtered = nil;
	self.pause = nil;
	self.filterLabel = nil;
    self.rawDataArray = nil;
    self.accelometerData = nil;
    self.motionManager = nil;
}

#pragma mark - ads
#pragma mark banner ad
// banner view delegate methods

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    [self.view addSubview:self.bannerView];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    //    [self layoutAnimated:YES];
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    
}


#pragma mark - Setup Instruction guide

- (void)setUpInstructionGuide
{
 
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, 424)];
    scrollView.tag = 110;
    scrollView.pagingEnabled = YES;
    scrollView.scrollEnabled = YES;
    scrollView.delegate = self;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    
    UITapGestureRecognizer *tap =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideGuide)];
    [scrollView addGestureRecognizer:tap];
    
    NSDictionary *dict1 = [NSDictionary dictionaryWithObjectsAndKeys:@"You need a iPhone or iPod touch with this app installed.",@"title",@"Sample-1.png",@"image", nil]; 
    
    NSDictionary *dict2 = [NSDictionary dictionaryWithObjectsAndKeys:@"You also need an arm case for your iPhone or iPod Touch.",@"title",@"Sample-2.png",@"image", nil]; 
    
    NSDictionary *dict3 = [NSDictionary dictionaryWithObjectsAndKeys:@"Put your iPhone & iPad touch around your left wrist if you are right-handed, vice versa for left-handed.",@"title",@"Sample-3.png",@"image", nil]; 
    
    NSDictionary *dict4 = [NSDictionary dictionaryWithObjectsAndKeys:@"This will be how you set up.",@"title",@"Sample-4.png",@"image", nil]; 
    
    NSArray *images = [NSArray arrayWithObjects:dict1,dict2,dict3,dict4, nil];
	for (int i = 0; i < images.count; i++) {
		CGRect frame;
		frame.origin.x = scrollView.frame.size.width * i;
		frame.origin.y = 0;
		frame.size = scrollView.frame.size;
		
	    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
        [imageView setImage:[UIImage imageNamed:[[images objectAtIndex:i] objectForKey:@"image"]]];
        imageView.userInteractionEnabled = YES;
		[scrollView addSubview:imageView];
        
        UILabel *instructionLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x + 20, 20.0, 280, 90)];
        instructionLabel.numberOfLines = 0;
        instructionLabel.lineBreakMode = UILineBreakModeWordWrap;
        instructionLabel.backgroundColor = [UIColor clearColor];
        instructionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17];
        instructionLabel.textColor = [UIColor orangeColor];
        
        instructionLabel.text = [[images objectAtIndex:i] objectForKey:@"title"];
        [scrollView addSubview:instructionLabel];
        
        if (i == 3) {
            UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            dismissButton.frame = CGRectMake(frame.origin.x + 20, 300.0, 70.0, 40.0);
            
            [dismissButton setTitle:@"I get it." forState:UIControlStateNormal];
            [dismissButton addTarget:self action:@selector(hideGuide) forControlEvents:UIControlEventTouchUpInside];
            dismissButton.titleLabel.textColor = [UIColor blackColor];
            dismissButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17];
            [scrollView addSubview:dismissButton];
            
            UIButton *goButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            goButton.frame = CGRectMake(frame.origin.x + 60, 370.0, 250.0, 40.0);
            
            [goButton setTitle:@"I get it. Don't show it again." forState:UIControlStateNormal];
            goButton.titleLabel.textColor = [UIColor blackColor];
            goButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17];
            [goButton addTarget:self action:@selector(dismissGuide) forControlEvents:UIControlEventTouchUpInside];
            
            [scrollView addSubview:goButton];

            
        }
        
        
	}
	
	scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * images.count, scrollView.frame.size.height);
    
	pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0.0, 424, 320, 44)];
    pageControl.backgroundColor = [UIColor blackColor];
    pageControl.tag = 111;
	pageControl.currentPage = 0;
	pageControl.numberOfPages = images.count;
    [pageControl addTarget:self action:@selector(changePage) forControlEvents:UIControlEventValueChanged];
    
    
    [self.view addSubview:scrollView];
    [self.view addSubview:pageControl];
    
    
    [self.view bringSubviewToFront:scrollView];
    [self.view bringSubviewToFront:pageControl];
}


- (void)scrollViewDidScroll:(UIScrollView *)sender {
	if (!pageControlBeingUsed) {
		// Switch the indicator when more than 50% of the previous/next page is visible
       CGFloat pageWidth = scrollView.frame.size.width;
        int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        pageControl.currentPage = page;
	}
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	pageControlBeingUsed = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	pageControlBeingUsed = NO;
}

- (void)changePage {
	// Update the scroll view to the appropriate page
	CGRect frame;
	frame.origin.x = self.scrollView.frame.size.width * self.pageControl.currentPage;
	frame.origin.y = 0;
	frame.size = self.scrollView.frame.size;
	[self.scrollView scrollRectToVisible:frame animated:YES];
	
	pageControlBeingUsed = YES;
}

- (void)dismissGuide{
    [self hideGuide];
    
    NSUserDefaults *defautls = [NSUserDefaults standardUserDefaults];
    [defautls setBool:YES forKey:@"ShowGuide"];
    [defautls synchronize];

}

- (void)hideGuide {
    [scrollView removeFromSuperview];
    [pageControl removeFromSuperview];

}

@end
