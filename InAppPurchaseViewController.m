//
//  RootViewController.m
//  InAppRage
//
//  Created by Liangjun Jiang on 2/28/11.
//  Copyright 2012 LJSport Apps All rights reserved.
//

#import "InAppPurchaseViewController.h"
#import "InAppIAPHelper.h"
#import "Reachability.h"
#import "SVProgressHUD/SVProgressHUD.h"

@implementation InAppPurchaseViewController
@synthesize delegate, mTable;

- (IBAction)done:(id)sender
{
    [SVProgressHUD dismiss];
    [self.delegate purchaseControllerDidFinish:self];
}


#pragma mark -
#pragma mark View lifecycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productsLoaded:) name:kProductsLoadedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:kProductPurchasedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(productPurchaseFailed:) name:kProductPurchaseFailedNotification object: nil];
    }
    return self;
}


- (void)viewDidLoad {
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    if (netStatus == NotReachable) {
        [SVProgressHUD showErrorWithStatus:@"No internet connection!"];
    } else {
//        NSLog(@"purchased: %@", [InAPPIAPHelper sharedHelper].purchasedProducts);
        
        if ([InAPPIAPHelper sharedHelper].products == nil) {
            
            [[InAPPIAPHelper sharedHelper] requestProducts];
            [SVProgressHUD showWithStatus:@"Loading..."];
            [self performSelector:@selector(timeout:) withObject:nil afterDelay:30.0];
        }
    }

}

- (void)dismissHUD:(id)arg {
    [SVProgressHUD dismiss];
    
}

- (void)productsLoaded:(NSNotification *)notification {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [SVProgressHUD dismiss];
    self.mTable.hidden = NO;
    
    [self.mTable reloadData];
    
}

- (void)timeout:(id)arg {
    
    [SVProgressHUD showErrorWithStatus:@"Timeout! Please try again later. "];
    [self performSelector:@selector(dismissHUD:) withObject:nil afterDelay:3.0];
}

- (void)updateInterfaceWithReachability: (Reachability*) curReach {
    
    
    
}


#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (section ==0)?1:[[InAPPIAPHelper sharedHelper].products count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.section ==0) {
        UIButton *buyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        buyButton.frame = CGRectMake(0, 0, 200, 37);
        [buyButton setTitle:NSLocalizedString(@"Restore", @"Restore") forState:UIControlStateNormal];
        buyButton.tag = indexPath.row;
        [buyButton addTarget:self action:@selector(restoreButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryView = buyButton;
        
        
    } else {
    
        // Configure the cell.
        SKProduct *product = [[InAPPIAPHelper sharedHelper].products objectAtIndex:indexPath.row];

        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [numberFormatter setLocale:product.priceLocale];
        NSString *formattedString = [numberFormatter stringFromNumber:product.price];

        cell.textLabel.text = product.localizedTitle;
        cell.detailTextLabel.text = formattedString;

        if ([[InAPPIAPHelper sharedHelper].purchasedProducts containsObject:product.productIdentifier]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell.accessoryView = nil;
        } else {        
            UIButton *buyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            buyButton.frame = CGRectMake(0, 0, 72, 37);
            [buyButton setTitle:@"Buy" forState:UIControlStateNormal];
            buyButton.tag = indexPath.row;
            [buyButton addTarget:self action:@selector(buyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.accessoryView = buyButton;     
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}
#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (IBAction)restoreButtonTapped:(id)sender
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (IBAction)buyButtonTapped:(id)sender {
    
    UIButton *buyButton = (UIButton *)sender;    
    SKProduct *product = [[InAPPIAPHelper sharedHelper].products objectAtIndex:buyButton.tag];
    
    [[InAPPIAPHelper sharedHelper] buyProductIdentifier:product.productIdentifier];
    
    [SVProgressHUD showWithStatus:@"Buying..."];
    
    [self performSelector:@selector(timeout:) withObject:nil afterDelay:60];
    
}

- (void)productPurchased:(NSNotification *)notification {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [SVProgressHUD dismiss];
//    NSString *productIdentifier = (NSString *) notification.object;
//    NSLog(@"Purchased: %@", productIdentifier);
    
    [self.mTable reloadData];    
    
}

- (void)productPurchaseFailed:(NSNotification *)notification {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [SVProgressHUD dismiss];
    
    SKPaymentTransaction * transaction = (SKPaymentTransaction *) notification.object;    
    if (transaction.error.code != SKErrorPaymentCancelled) {
        [SVProgressHUD showErrorWithStatus:transaction.error.localizedDescription];
    }
    
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kProductPurchaseFailedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kProductPurchasedNotification object:nil];
}

@end

