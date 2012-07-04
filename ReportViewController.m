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

@interface ReportViewController ()<MFMailComposeViewControllerDelegate>

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

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.rawData = nil;
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
            return @"Number of swing attempted";
            break;
        case 1:
            return @"";
            break;
        case 2:
            return @"What't the graph & data says";
            break;
        case 3:
            return @"How the model is built";
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
            return 2;
            break;
        case 3:
            return 1;
        default:
            break;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
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
    
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"MMddyyyyhhmmss"];
//    NSString *fileName = [NSString stringWithFormat:@"%@.csv",[formatter stringFromDate:[NSDate date]]];
//    NSMutableString *tempStr = [NSMutableString stringWithString:@"here is my test!"];
//    NSLog(@"what's raw data string:%@",rawDataString);
//    [self writeToFile:tempStr withFileName:fileName];
//    
//    if ([DocumentManager filePathInDocument:fileName]) {
//        NSData *fileData = [NSData dataWithContentsOfFile:[DocumentManager filePathInDocument:fileName]];
//        
//        [picker addAttachmentData:fileData mimeType:@"application/octet-stream" fileName:fileName];
//        
//        // Fill out the email body text
//        NSString *emailBody = @"Raw data!";
//        [picker setMessageBody:emailBody isHTML:NO];
//        
//        [self presentModalViewController:picker animated:YES];
//    }
    
    
    
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
