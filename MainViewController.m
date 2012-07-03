/*
     File: MainViewController.m
 Abstract: Responsible for all UI interactions with the user and the accelerometer
  Version: 2.5
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2010 Apple Inc. All Rights Reserved.
 
*/

#import "MainViewController.h"
#import "GraphView.h"
#import "AccelerometerFilter.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "DocumentManager.h"
#import <CoreMotion/CoreMotion.h>

#define kUpdateFrequency	60.0
#define kLocalizedPause		NSLocalizedString(@"Pause","pause taking samples")
#define kLocalizedResume	NSLocalizedString(@"Resume","resume taking samples")
#define kLocalizedShare		NSLocalizedString(@"Share","share the data")

@interface MainViewController()<MFMailComposeViewControllerDelegate>{
    NSMutableArray *rawDataArray;
    NSMutableString *rawDataString;
    
    CMMotionManager *motionManager;

}
@property (nonatomic) NSMutableArray *rawDataArray;
@property (nonatomic) NSMutableString *rawDataString;
@property (nonatomic, strong) CMMotionManager *motionManager;

// Sets up a new filter. Since the filter's class matters and not a particular instance
// we just pass in the class and -changeFilter: will setup the proper filter.
-(void)changeFilter:(Class)filterClass;

@end

@implementation MainViewController

@synthesize unfiltered, filtered, pause, filterLabel,share, sensor;
@synthesize rawDataArray,rawDataString;
@synthesize motionManager;

- (void)flipsideViewControllerDidFinish:(LJFlipsideViewController *)controller
{
    [self dismissModalViewControllerAnimated:YES];
}


- (void)discloseSetting:(id)sender
{
    LJFlipsideViewController *ljfvc = [[LJFlipsideViewController alloc] initWithNibName:@"LJFlipsideViewController" bundle:nil];
    ljfvc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:ljfvc animated:YES];
    
    
}


// Implement viewDidLoad to do additional setup after loading the view.
-(void)viewDidLoad
{
	[super viewDidLoad];
    
  	pause.possibleTitles = [NSSet setWithObjects:kLocalizedPause, kLocalizedResume, nil];
    share.possibleTitles = [NSSet setWithObjects:kLocalizedShare, nil];
	isPaused = NO;
	useAdaptive = NO;
	[self changeFilter:[LowpassFilter class]];
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:1.0 / kUpdateFrequency];
	[[UIAccelerometer sharedAccelerometer] setDelegate:self];
	
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
    self.rawDataString = nil;
    self.sensor = nil;
    self.share = nil;
    self.motionManager = nil;
}

// UIAccelerometerDelegate method, called when the device accelerates.
-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
	// Update the accelerometer graph view
	if(!isPaused)
	{
		[filter addAcceleration:acceleration];
        
//        NSMutableString *tempDataString = [NSMutableString stringWithString:@""];
//
//        NSString *tempString = [NSString stringWithFormat:@"%f %f %f",acceleration.x, acceleration.y,acceleration.z];
//        [tempDataString appendString:tempString];
//        
//        NSLog(@"%@",tempDataString); 
        //Red line: x, Green line: y, Blue line: z
		[unfiltered addX:acceleration.x y:acceleration.y z:acceleration.z];
//        NSLog(@"filter x=%f, y=%f, z=%f",filter.x, filter.y,filter.z);
		[filtered addX:filter.x y:filter.y z:filter.z];
	}
}

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
	}
	else
	{
		// If we are not paused, then pause and set the title to "Resume"
		isPaused = YES;
		pause.title = kLocalizedResume;
	}
	
	// Inform accessibility clients that the pause/resume button has changed.
	UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
    
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


- (IBAction)changeSensor:(id)sender{
    UIBarButtonItem *mSensor = (UIBarButtonItem *)sender;
    if ([mSensor.title isEqualToString:@"Accelerometer"]) {
        mSensor.title = @"Gyroscope";
        isPaused = YES;
        
        motionManager = [[CMMotionManager alloc] init];
        
        motionManager.deviceMotionUpdateInterval = 1.0/60.0;
        
        if (motionManager.deviceMotionAvailable) {
            [motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion *motion, NSError *error){
                [self performSelector:@selector(performLogDeviceMotion:) onThread:[NSThread mainThread] withObject:motion waitUntilDone:YES];
                
            }];
        } else {
            NSLog(@"Device Motion is not available!");
            motionManager = nil;
        }
                
    } else {
        mSensor.title = @"Accelerometer";
        [motionManager stopDeviceMotionUpdates];

    }
    
    // Inform accessibility clients that the pause/resume button has changed.
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
    
}


- (void)performLogDeviceMotion: (CMDeviceMotion *)motion{
    
    // Refer to: http://en.wikipedia.org/wiki/File:Rollpitchyawplain.png
    // to get the concept of roll, yaw and pitch
//    CMAttitude *attitude = motion.attitude;
//    NSLog(@"attitude roll:%f radiants, attitude pitch:%f radians, attitude yaw:%f radians", attitude.roll, attitude.pitch, attitude.yaw);
    
    CMRotationRate rotationRate = motion.rotationRate;
    NSLog(@"rotation x: %f rad/sec, rotation y:%f rad/sec, rotation z:%f rad/sec",rotationRate.x, rotationRate.y, rotationRate.z);
    
//    CMAcceleration acceration = motion.userAcceleration; 
//    NSLog(@"rotation x: %f m/s^2, rotation y:%f m/s^2, rotation z:%f m/s^2",acceration.x, acceration.y, acceration.z);
    
//    [filter addAcceleration:attitude];
//    [filter addAttitude:attitude];
    [filter addRotation:rotationRate];
    //        NSMutableString *tempDataString = [NSMutableString stringWithString:@""];
    //
    //        NSString *tempString = [NSString stringWithFormat:@"%f %f %f",acceleration.x, acceleration.y,acceleration.z];
    //        [tempDataString appendString:tempString];
    //        
    //        NSLog(@"%@",tempDataString); 
    //Red line: x, Green line: y, Blue line: z
//    [unfiltered addX:attitude.roll y:attitude.pitch z:attitude.yaw];
    [unfiltered addRotationX:rotationRate.x y:rotationRate.y z:rotationRate.z];
//    [unfiltered add
    //        NSLog(@"filter x=%f, y=%f, z=%f",filter.x, filter.y,filter.z);
//    [filtered addX:filter.x y:filter.y z:filter.z];
    [filtered addRotationX:rotationRate.x y:rotationRate.y z:rotationRate.z];
    
    
}


// TODO: CHANGE TO ICLOUD
#pragma mark -
- (void)writeToFile:(NSMutableString *)mutableString withFileName:(NSString *)fileName
{
    
    NSError *error;
    
    NSString *documentsDirectory = [NSHomeDirectory() 
                                    stringByAppendingPathComponent:@"Documents"];
    
    NSString *filePath = [documentsDirectory 
                          stringByAppendingPathComponent:fileName];
    
    
    // Write to the file
    [mutableString writeToFile:filePath atomically:YES
                    encoding:NSUTF8StringEncoding error:&error];
}

- (IBAction)share:(id)sender
{
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass != nil)
    {
        // We must always check whether the current device is configured for sending emails
        if ([mailClass canSendMail])
        {
            [self displayComposerSheet];
        }
    }

}


- (void)displayComposerSheet{
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    [picker setSubject:@"Your data!"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMddyyyyhhmmss"];
    NSString *fileName = [NSString stringWithFormat:@"%@.csv",[formatter stringFromDate:[NSDate date]]];
    NSMutableString *tempStr = [NSMutableString stringWithString:@"here is my test!"];
    NSLog(@"what's raw data string:%@",rawDataString);
    [self writeToFile:tempStr withFileName:fileName];
    
    if ([DocumentManager filePathInDocument:fileName]) {
        NSData *fileData = [NSData dataWithContentsOfFile:[DocumentManager filePathInDocument:fileName]];
        
        [picker addAttachmentData:fileData mimeType:@"application/octet-stream" fileName:fileName];
        
        // Fill out the email body text
        NSString *emailBody = @"Raw data!";
        [picker setMessageBody:emailBody isHTML:NO];
        
        [self presentModalViewController:picker animated:YES];
    }
    
    
    
}

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{   
    //    message.hidden = NO;
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            //            message.text = @"Result: canceled";
            break;
        case MFMailComposeResultSaved:
            //            message.text = @"Result: saved";
            break;
        case MFMailComposeResultSent:
            //            message.text = @"Result: sent";
            break;
        case MFMailComposeResultFailed:
            //            message.text = @"Result: failed";
            break;
        default:
            //            message.text = @"Result: not sent";
            break;
    }
    [self dismissModalViewControllerAnimated:YES];
}


@end
