//
//  LeveyPopListView.m
//  LeveyPopListViewDemo
//
//  Created by Levey on 2/21/12.
//  Copyright (c) 2012 Levey. All rights reserved.
//

#import "PopListView.h"
#import <QuartzCore/QuartzCore.h>
#import <StoreKit/StoreKit.h>
#import "InAPPIAPHelper.h"
@interface BypassGeoHeader : UIView
@property (nonatomic, strong) UILabel *titleLabel;
- (void)setTitle:(NSString*)title;
@end

@implementation BypassGeoHeader
@synthesize titleLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *containerBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"geo_location_tab@2X.png"]];
        containerBackground.frame = CGRectMake(0.0, 0.0, 270.0, 50.0);
        [self addSubview:containerBackground];
        
        UIImageView *geoMarkerImageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"geo_location_map_marker@2X.png"]];
        geoMarkerImageview.frame = CGRectMake(21.0, 14.0, 19.0, 21.0);
        [self addSubview:geoMarkerImageview];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(42.0, 14.0, 175.0, 21.0)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0]; // We hard-coded this!
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.textAlignment = UITextAlignmentCenter;
        titleLabel.tag = 112;
        [self addSubview:titleLabel];
        
        UIImageView *geoLocationArrowImageview = [[UIImageView alloc] initWithFrame:CGRectMake(225.0, 10.0, 29.0, 30.0)];
        geoLocationArrowImageview.image = [UIImage imageNamed:@"geo_location_arrow_before"];
        geoLocationArrowImageview.tag = 113;
        [self addSubview:geoLocationArrowImageview];
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
}
@end



@interface PopListView ()<UITableViewDataSource, UITableViewDelegate>{
    NSString *_title;
    NSDictionary *_dataDict;
}
@end

@interface PopListView (private)
- (void)fadeIn;
- (void)fadeOut;
@end

@implementation PopListView
@synthesize delegate;

- (id)initWithData:(NSDictionary *)aDict{
    CGRect rect = CGRectMake(25.0, 70.0, 270, 270);
    if (self = [super initWithFrame:rect])
    {
        self.backgroundColor = [UIColor clearColor];
        _dataDict = [aDict copy];
        
        BypassGeoHeader *geoHeader = [[BypassGeoHeader alloc] initWithFrame:CGRectMake(0.0, 0.0, 270, 50)];
        [self addSubview:geoHeader];
        
        UILabel *titleLabel = (UILabel *)[self viewWithTag:112];
        titleLabel.text = [aDict objectForKey:@"title"];
        
        CALayer *topBorder = [CALayer layer];
        topBorder.frame = CGRectMake(4.0f, 40.0f, 262, 2.0f);
        topBorder.backgroundColor = [UIColor whiteColor].CGColor;
        [geoHeader.layer addSublayer:topBorder];
        
        UITableView *mTableView = [[UITableView alloc] initWithFrame:CGRectMake(4.0, 42.0, 262.0, 220)];
        mTableView.separatorColor = [UIColor colorWithWhite:0.8 alpha:1.0];
        mTableView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        mTableView.showsVerticalScrollIndicator = YES;
        mTableView.dataSource = self;
        mTableView.delegate = self;
        
        //Create shadows
        self.layer.shadowOffset = CGSizeZero;
        self.layer.shadowOpacity = 0.75f;
        self.layer.shadowRadius = 5.0f;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.layer.bounds].CGPath;
        self.clipsToBounds = NO;
        
        [self addSubview:mTableView];
        
        
    }
    return self;
    
}

#pragma mark - Private Methods
- (void)fadeIn
{
    self.transform = CGAffineTransformMakeScale(1.3, 1.3);
    self.alpha = 0;
    [UIView animateWithDuration:.35 animations:^{
        self.alpha = 1;
        self.transform = CGAffineTransformMakeScale(1, 1);
    }];
        
}
- (void)fadeOut
{
    [UIView animateWithDuration:.35 animations:^{
        self.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

#pragma mark - Instance Methods
- (void)showInView:(UIView *)aView animated:(BOOL)animated
{
    [aView addSubview:self];
    if (animated) {
        [self fadeIn];
    }
}

#pragma mark - Tableview datasource & delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_dataDict objectForKey:@"value"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentity = @"PopListCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentity];
    if (cell ==  nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentity];
    }
    int row = [indexPath row];

    NSArray *valueArray = [_dataDict objectForKey:@"value"];
    
    SKProduct *product = [valueArray objectAtIndex:row];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:product.priceLocale];
    NSString *formattedString = [numberFormatter stringFromNumber:product.price];
    cell.textLabel.text = product.localizedTitle;
    cell.detailTextLabel.text = formattedString;
    
    if ([[InAPPIAPHelper sharedHelper].purchasedProducts containsObject:product.productIdentifier]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.accessoryView = nil;
    } else {
        UIButton *buyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        buyButton.frame = CGRectMake(0.0, 0.0, 72.0, 37.0);
        [buyButton setTitle:@"buy" forState:UIControlStateNormal];
        buyButton.tag = indexPath.row;
        [buyButton addTarget:self action:@selector(buyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryView = buyButton;
    }
    
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // tell the delegate the selection
    if (self.delegate && [self.delegate respondsToSelector:@selector(popListView:didSelectedIndex:)]) {
        [self.delegate popListView:self didSelectedIndex:[indexPath row]];
    }
    
    // dismiss self
    [self fadeOut];
}
#pragma mark - TouchTouchTouch
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // tell the delegate the cancellation
    if (self.delegate && [self.delegate respondsToSelector:@selector(popListViewDidCancel)]) {
        [self.delegate popListViewDidCancel];
    }
    
    // dismiss self
    [self fadeOut];
}



@end
