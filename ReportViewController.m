//
//  ReportViewController.m
//  AccelerometerGraph
//
//  Created by Liangjun Jiang on 7/2/12.
//  Copyright (c) 2012 ByPass Lane. All rights reserved.
//

#import "ReportViewController.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

#define THRESHOLD 0.90  // this is used to collect the peak value +/- 90% of the max swing speed detected. 
#define EFFECTIVE_POINTS 180
#define NOISE_FLOOR 0.02 // *9.8 m/s^2 as noise floor

#pragma mark - Help class to show the name prompt
@interface NameAlertPrompt : UIAlertView {
    UITextField *textField;
}

@property (nonatomic, retain) UITextField *textField;
@property (readonly) NSString *enteredText;
- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okButtonTitle;

@end


@implementation NameAlertPrompt
@synthesize textField, enteredText;

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okayButtonTitle {
    
    self = [super initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:okayButtonTitle, nil];
    
    if (self) {
        UITextField *theTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)]; 
        [theTextField setBackgroundColor:[UIColor whiteColor]]; 
        [theTextField setSecureTextEntry:YES];
        [theTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [theTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
        [self addSubview:theTextField];
        self.textField = theTextField;
    }
    return self;
}

- (void)show {
    [textField becomeFirstResponder];
    [super show];
}

- (NSString *)enteredText {
    return textField.text;
}

@end



@interface ReportViewController ()<UIAlertViewDelegate, MFMailComposeViewControllerDelegate>{
    int count;
    float max;
    float mean;
    float standardDeviation;
    
    float maxAccX;
    float meanAccX;
    float sdAccx;
    
}
@property (nonatomic, strong) IBOutlet UITableView *mTableView;

@property (nonatomic, strong) IBOutlet UINavigationBar *navBar;
@property (nonatomic, strong) NSMutableArray *countableSwings;
@property (nonatomic, strong) NSMutableArray *countableSwingTempos;
@property (nonatomic, strong) NSDictionary *calculatedSwingTempo;


@end

@implementation ReportViewController
@synthesize delegate = _delegate, mTableView = _mTableView,  navBar;
@synthesize rawData = _rawData, accelormeterData = _accelormeterData;
@synthesize countableSwings, countableSwingTempos, calculatedSwingTempo;

- (IBAction)done:(id)sender
{
    [self.delegate reportViewControllerDidFinish:self];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *title;
    if ([defaults objectForKey:CLUB]) {
        title = [[defaults objectForKey:CLUB] objectForKey:@"name"];
    } else {
        title = @"Driver";
    }
   
    self.navBar.topItem.title = title;
    
    
    // We do some simple math
    
    max = 0.0;
    mean = 0.0;
    standardDeviation = 0.0;
    
    max = [self calculateMax:self.rawData];
    countableSwings = [self calculateCountableFromRawData:self.rawData withThreshold:max];
    mean = [self calculateMean:countableSwings];
    standardDeviation = sqrtf([self calculateVariance:countableSwings withMean:mean]);
    
    
    maxAccX =  0.0;
    meanAccX = 0.0;
    sdAccx = 0.0;
    
    NSMutableArray *cacluatingTempo = [NSMutableArray array];
    [self.accelormeterData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [cacluatingTempo addObject:[(NSDictionary *)obj objectForKey:@"accX"]];
    }];
    maxAccX = [self calculateSwingTempoMax:cacluatingTempo];
    countableSwingTempos = [self calculateCountableFromRawData:cacluatingTempo withThreshold:maxAccX];
    
    meanAccX = [self calculateMean:countableSwingTempos];
    sdAccx = sqrtf([self calculateVariance:countableSwingTempos withMean:meanAccX]);
    
    NSLog(@"max : %.2f, mean: %.2f and St: %.2f",maxAccX, meanAccX, sdAccx);
    
    calculatedSwingTempo = [NSDictionary dictionaryWithDictionary:[self calculateSwingTempo:cacluatingTempo withMax:maxAccX]];
    NSLog(@"dict : %@",calculatedSwingTempo);
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    _mTableView = nil;
    _rawData = nil;
    countableSwings = nil;
    _accelormeterData = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    switch (section) {
        case 0:
            return @"Number of Swing Counted";
            break;
        case 1:
            return @"Distribution [MPH]";
            break;
        case 2:
            return @"Counted Club Speed [MPH]";
            break;
        case 3:
            return @"Calculated Swing Tempo [SECONDS]";
            break;
        default:
            break;
    }
    
    return nil;
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 3;
            break;
        case 2:
            return [countableSwings count];
            break;
        case 3:
            return 2;
            break;
        default:
            break;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    switch (section) {
        case  0:
            switch (row) {
                case 0:
                    cell.textLabel.text = [NSString stringWithFormat:@"%d", [countableSwings count]];
                    break;
                    
                default:
                    break;
            }
            break;
        case 1:
            switch (row) {
                case 0:
                    cell.textLabel.text = [NSString stringWithFormat:@"Max: %.2f",max];
                    break;
                case 1:
                    cell.textLabel.text = [NSString stringWithFormat:@"Mean: %.2f",mean];
                    break;
                case 2:
                    cell.textLabel.text = [NSString stringWithFormat:@"Standard Deviation: %.2f",standardDeviation];
                    break;
                default:
                    break;
            }
            break;
        case 2:
            cell.textLabel.text = [NSString stringWithFormat:@"%.2f",[[countableSwings objectAtIndex:row] floatValue]];
            break;
            
        case 3:
        {
            cell.textLabel.text = (row == 0)?[NSString stringWithFormat:@"Backswing: %.2f sec",[[calculatedSwingTempo objectForKey:@"backSwing"] floatValue] * 1.0/60.0]:[NSString stringWithFormat:@"Downswing: %.2f sec",[[calculatedSwingTempo objectForKey:@"downSwing"] floatValue]* 1.0/60.0];
            break;
        }
        default:
            break;
    }
    
    
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

#pragma mark - help methods
- (float )calculateMax:(NSMutableArray *)mData{
    float localMax = 0.0;
    
    for (NSNumber *number in mData){
        if ([number floatValue] > 0) {
            if ([number floatValue] > localMax) {
                localMax = [number floatValue];
            }
        }
        else  {
            if (-[number floatValue] > localMax) {
                localMax = -[number floatValue];
            }
            
            return -localMax;
        }
    }
    
    return localMax;
}


// to measure swing tempo's max
- (float)calculateSwingTempoMax:(NSArray *)mData
{
    NSNumber* min = [mData valueForKeyPath:@"@min.self"];
    NSNumber* maxV = [mData valueForKeyPath:@"@max.self"];
    return fabs([min floatValue] > fabs([maxV floatValue]))?[min floatValue]:[maxV floatValue];
}

// we use +/- 20% of the max to get other peak values
- (NSMutableArray *)calculateCountableFromRawData:(NSMutableArray *)mData withThreshold:(float)mMax
{
    NSMutableArray *localArray = [NSMutableArray array];
    for (NSNumber *number in mData) {
        if ([number floatValue] > THRESHOLD*mMax)
            [localArray addObject:number];
    }
    
    return localArray;
    
}

- (float)calculateMean:(NSMutableArray *)mData
{
    
    float sum = 0.0;
    for (NSNumber *number in mData){
        sum  += [number floatValue];
    }
    
    return sum / [mData count];
}

- (float)calculateVariance:(NSMutableArray *)mData withMean:(float)mMean
{
    float sum = 0.0;
    for (NSNumber *number in mData) {
        sum += fabsf(mMean - [number floatValue])*fabsf(mMean - [number floatValue]);
    }
    return sum / [mData count];
}


- (NSDictionary *)calculateSwingTempo:(NSMutableArray *)mData withMax:(float)mMax{
        
    int downswingFirstPart = 0;
    int downswingSecondPart = 0;

    int backswingFirstPart = 0;
    int backswingSecondPart = 0;
    
    NSUInteger maxIndex = 0;
    
    if ([mData containsObject:[NSNumber numberWithFloat:mMax]]) {
        maxIndex = [mData indexOfObject:[NSNumber numberWithFloat:mMax]];
    }
    
    NSLog(@"what's the max happended :%d",maxIndex);
    
    /* Now this is the fun part
    * We already have the index for the max value which has to be at the bottom of downswing
    * We starts from those, follow back (to backswing) with 2/3 of total points, and 1/3 of back to follow through part.
    * We compare each point with +/- 0.03 (we think it's noise floor)/
    * we want to find the first 0 which should be the swing starting point, the 2nd 0 which is the top of backswing. The two should be the backswing time
    * We want to find the third 0 which should be the end of following through (
    * If the user continues to swing, it could be another 0
    */
    for (int i = maxIndex; i < [mData count]; i++) {
        if (fabs([[mData objectAtIndex:i] floatValue]> fabs(NOISE_FLOOR)) ) {
            downswingSecondPart++;
        }
    }
    
    for (int j = maxIndex*0.3; j < maxIndex; j++) {
        if ([[mData objectAtIndex:j] floatValue]> NOISE_FLOOR) {
            backswingFirstPart ++;
        } else if ([[mData objectAtIndex:j] floatValue]< -NOISE_FLOOR){
            downswingFirstPart ++;
        }
    }
    
    return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:backswingFirstPart],@"backSwing",[NSNumber numberWithInt:downswingFirstPart + backswingSecondPart],@"downSwing", nil];
}

#pragma mark - Mail Delegate

- (IBAction)sendFeedback:(id)sender
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
    
    [picker setSubject:@"I'd like to hear from you!"];
    
    [picker setToRecipients:[NSArray arrayWithObject:@"2010.longhorn@gmail.com"]];
    
    NSString *emailBody = @"Do you think if the data make sense? Send me your comment and suggestion";
    
    [picker setMessageBody:emailBody isHTML:NO];
            
    [self presentModalViewController:picker animated:YES];
    
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


#pragma mark - Alert View Delegate
- (void)alertViewCancel:(UIAlertView *)alertView
{
    NSLog(@"User Cancelled");
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            break;
            
        default:
            NSLog(@"Save the user!");
            break;
    }
    
}

@end
