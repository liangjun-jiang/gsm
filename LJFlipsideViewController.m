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

@property (nonatomic, strong) NSArray *handed;
@property (nonatomic, strong) NSArray *positions;
@property (nonatomic, strong) NSArray *clubs;
@property (nonatomic, strong) NSString *currentPosition;
@property (nonatomic, strong) NSString *currentClub;


@end

@implementation LJFlipsideViewController

@synthesize delegate = _delegate;
@synthesize mTable = _mTable;
@synthesize handed = _handed, positions = _positions, clubs = _clubs, currentClub = _currentClub, currentPosition = _currentPosition;
- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _handed = [NSArray arrayWithObjects:@"Left-handed",@"Right-handed", nil];
    _positions = [NSArray arrayWithObjects:@"Wrist",@"Upper Arm", nil];
    
    NSString *file = [[NSBundle mainBundle] pathForResource:@"Clubs" ofType:@"plist"];
    _clubs = [NSArray arrayWithContentsOfFile:file];
//    _clubs = [NSArray arrayWithObjects:@"Driver",@"3-Wood",@"5-Wood",@"7-Iron", nil];
    
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
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    switch (section) {
        case 0:
            return @"You are";
            break;
        case 1:
            return @"You put device around";
            break;
        case 2:
            return @"You are praticing";
            break;
        default:
            break;
    }
    return 0;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    switch (section) {
        case 0:
            return [_handed count];
            break;
        case 1:
            return [_positions count];
            break;    
        case 2:
            return [_clubs count];
            break;    
        default:
            break;
    }
    
    return 0;
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
            cell.textLabel.text = [_handed objectAtIndex:indexPath.row];
            if (indexPath.row == 0) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            break;
        case 1:
            cell.textLabel.text = [_positions objectAtIndex:indexPath.row];
            if (indexPath.row == 1) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            break;
        default:
            cell.textLabel.text = [[_clubs objectAtIndex:indexPath.row] objectForKey:@"name"];
            cell.detailTextLabel.text = [NSString stringWithFormat:@" inch", [[_clubs objectAtIndex:indexPath.row] objectForKey:@"length"]];
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
    [tableView reloadData];
}

@end
