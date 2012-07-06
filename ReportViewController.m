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

#define THRESHOLD 0.90


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
        //CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, 130.0); 
        //[self setTransform:translate];
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
    NSMutableArray *countableSwings;
    float max;
    float mean;
    float standardDeviation;
    
}

@end

@implementation ReportViewController
@synthesize delegate = _delegate, mTableView = _mTableView, rawData = _rawData, navBar = _navBar;

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
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.mTableView = nil;
    self.rawData = nil;
    countableSwings = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
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
        default:
            break;
    }
    
    
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    switch (section) {
        case 0:
            [tableView  deselectRowAtIndexPath:indexPath animated:NO];
            break;
        case 1:
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            break;
        case 2:
            
        default:
            break;
    }
}

#pragma mark - help methods
- (float )calculateMax:(NSMutableArray *)mData{
    float localMax = 0.0;
    
    for (NSNumber *number in mData){
        if ([number floatValue] > localMax) {
            localMax = [number floatValue];
        }
    }
    
    return localMax;
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
