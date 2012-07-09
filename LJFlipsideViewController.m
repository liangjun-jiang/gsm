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
@property (nonatomic, strong) NSString *currentHand;

@property (nonatomic, strong) NSString *currentPosition;
@property (nonatomic, strong) NSDictionary *currentClub;


@end

@implementation LJFlipsideViewController

@synthesize delegate = _delegate;
@synthesize mTable = _mTable;
@synthesize handed = _handed, positions = _positions, clubs = _clubs, currentClub = _currentClub, currentPosition = _currentPosition, currentHand = _currentHand;
- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _handed = [NSArray arrayWithObjects:@"Right-handed",@"Left-handed", nil];
    _positions = [NSArray arrayWithObjects:@"Wrist", nil];
    
    NSString *file = [[NSBundle mainBundle] pathForResource:@"Clubs" ofType:@"plist"];
    _clubs = [[NSDictionary dictionaryWithContentsOfFile:file] objectForKey:@"root"];
    
    // We make the array reversed
    _clubs = [[_clubs reverseObjectEnumerator] allObjects];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:HANDED]) self.currentHand = [defaults objectForKey:HANDED];
    if ( [defaults objectForKey:POSITION]) {
        self.currentPosition = [defaults objectForKey:POSITION];
    }
    
    if ([defaults objectForKey:CLUB]) {
        self.currentClub = [defaults objectForKey:CLUB];
    }
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.mTable = nil;
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

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return (section == 2)? 40.0:0.0;
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
    
    switch (indexPath.section) {
        case 0:
            {
                cell.textLabel.text = [_handed objectAtIndex:indexPath.row];
                
                if (self.currentHand) {
                    NSUInteger index = [_handed indexOfObject:self.currentHand];
                    if (indexPath.row == index) {
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    }
                } else {
                    if (indexPath.row == 0) {
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        self.currentHand = [_handed objectAtIndex:0];
                    }
                }
                break;
            }
        case 1:
            {
                cell.textLabel.text = [_positions objectAtIndex:indexPath.row];
                if (self.currentPosition) {
                    NSUInteger index = [_positions indexOfObject:self.currentPosition];
                    if (indexPath.row == index) {
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    }
                } else {
                    if (indexPath.row == 0) {
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        self.currentPosition = [_positions objectAtIndex:0];
                    }
                }
                break;
            }
        default:
            {
                cell.textLabel.text = [[_clubs objectAtIndex:indexPath.row] objectForKey:@"name"];
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ inch", [[_clubs objectAtIndex:indexPath.row] objectForKey:@"length"]];
                if (self.currentClub) {
                    NSUInteger index = [_clubs indexOfObject:self.currentClub];
                    if (indexPath.row == index) {
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    }
                } else {
                    if (indexPath.row == 0) {
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        self.currentClub = [_clubs objectAtIndex:0];
                    }
                }
                break;
            }
    }
    
    return cell;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSInteger section = indexPath.section;
    
    NSInteger currentIndex = 0;
    
    NSIndexPath *oldIndexPath;
    
    switch (section) {
        case 0:
            currentIndex = [_handed indexOfObject:self.currentHand];
            oldIndexPath = [NSIndexPath indexPathForRow:currentIndex inSection:0];
            break;
        case 1:
            currentIndex = [_positions indexOfObject:self.currentPosition];
            oldIndexPath = [NSIndexPath indexPathForRow:currentIndex inSection:1];
            
            break;
        case 2:
            currentIndex = [_clubs indexOfObject:self.currentClub];
            oldIndexPath = [NSIndexPath indexPathForRow:currentIndex inSection:2];
            break;
        default:
            break;
    }
    
    if (currentIndex == indexPath.row) {
        return;
    }
    
    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    if (newCell.accessoryType == UITableViewCellAccessoryNone) {
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if (section == 0) {
            self.currentHand = [_handed objectAtIndex:indexPath.row];
            [defaults setObject:self.currentHand forKey:HANDED];
        } else if (section == 1){
            self.currentPosition = [_positions objectAtIndex:indexPath.row];
            [defaults setObject:self.currentPosition forKey:POSITION];
        } else if (section == 2){
            self.currentClub = [_clubs objectAtIndex:indexPath.row];
            [defaults setObject:self.currentClub forKey:CLUB];
        }
        
        [defaults synchronize];
        
    }
    
    UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
    if (oldCell.accessoryType == UITableViewCellAccessoryCheckmark) {
        oldCell.accessoryType = UITableViewCellAccessoryNone;
    }
//    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:oldIndexPath, indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
}

@end
