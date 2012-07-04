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

@interface ReportViewController ()<MFMailComposeViewControllerDelegate>{
    
    int count;
    NSMutableArray *countableSwings;
    float max;
    float mean;
    float standardDeviation;
    
}

@end

@implementation ReportViewController
@synthesize delegate = _delegate, mTableView = _mTableView, rawData = _rawData;

- (IBAction)done:(id)sender
{
    [self.delegate reportViewControllerDidFinish:self];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Let's do some math here
    // We use an array to keep track of the 
    
    max = 0.0;
    mean = 0.0;
    standardDeviation = 0.0;
    
    max = [self calculateMax:self.rawData];
    
    mean = [self calculateMean:self.rawData];
    standardDeviation = sqrtf([self calculateVariance:self.rawData withMean:mean]);
    
    countableSwings = [self calculateCountableFromRawData:self.rawData withThreshold:max];
    
    [self.mTableView reloadData];
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
            return @"Number of Swing counted";
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
        if ([number floatValue] > 0.80*mMax)
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

@end
