//
//  LJFlipsideViewController.m
//  SwingTracker
//
//  Created by Liangjun Jiang on 6/20/12.
//  Copyright (c) 2012 ByPass Lane. All rights reserved.
//

#import "LJFlipsideViewController.h"

@interface LJFlipsideViewController (){
    
    
}

@property (nonatomic, strong) NSArray *positions;
@property (nonatomic, strong) NSArray *clubs;
@property (nonatomic, strong) NSString *currentPosition;
@property (nonatomic, strong) NSString *currentClub;


@end

@implementation LJFlipsideViewController

@synthesize delegate = _delegate;
@synthesize mTable = _mTable;
@synthesize positions = _positions, clubs = _clubs, currentClub = _currentClub, currentPosition = _currentPosition;
- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _positions = [NSArray arrayWithObjects:@"Wrist",@"Upper Arm", nil];
    _clubs = [NSArray arrayWithObjects:@"Driver",@"3-Wood",@"5-Wood",@"7-Iron", nil];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self.delegate flipsideViewControllerDidFinish:self];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    return (section == 0)? @"Device Position":@"Club Selection";
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return (section == 0)?[_positions count]:[_clubs count];
    
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath   

{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.text = (indexPath.section == 0)?[_positions objectAtIndex:indexPath.row]:[_clubs objectAtIndex:indexPath.row];
    
    switch (indexPath.section) {
        case 0:
            if (indexPath.row == 1) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            break;
            
        default:
            if (indexPath.row == 0) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            break;
    }
    
    return cell;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSInteger section = indexPath.section;
    
    NSInteger currentIndex = (section == 0)? [_positions indexOfObject:self.currentPosition]:[_clubs indexOfObject:self.currentClub];
    if (currentIndex == indexPath.row) {
        return;
    }
    NSIndexPath *oldIndexPath = (section == 0)?[NSIndexPath indexPathForRow:currentIndex inSection:0]:[NSIndexPath indexPathForRow:currentIndex inSection:1];
    
    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    if (newCell.accessoryType == UITableViewCellAccessoryNone) {
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        if (section == 0) {
            self.currentPosition = [_positions objectAtIndex:indexPath.row];
        } else if (section == 1){
            self.currentClub = [_clubs objectAtIndex:indexPath.row];
        }
        
    }
    
    // Why this doesn't work?
    UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
    if (oldCell.accessoryType == UITableViewCellAccessoryCheckmark) {
        oldCell.accessoryType = UITableViewCellAccessoryNone;
    }
}

@end
