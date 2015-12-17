//
//  HomeViewController.m
//  LocalPlaces
//
//  Created by Rayan on 17/12/15.
//  Copyright © 2015 Rayan. All rights reserved
//

#import "HomeViewController.h"

#import "PlaceListViewController.h"
#import "SettingsViewController.h"
#import "PlaceTypeTVCell.h"

#import <CoreLocation/CoreLocation.h>

@interface HomeViewController () <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *categoryTableView;

@end

@implementation HomeViewController {
    
    CLLocationManager *locationManager;
}


#pragma mark - UIViewController Events

- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
	titleLabel.text = @"Home";
	titleLabel.textColor = APP_TITLE_FONT_COLOR;
	titleLabel.font = APP_TITLE_FONT;
	self.navigationItem.titleView = titleLabel;
	
	self.categoryTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
	self.categoryTableView.dataSource = self;
	self.categoryTableView.delegate = self;
    
    UIImage *settingsImage = [UIImage imageNamed:@"iconSettings.png" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
    UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingsButton setFrame:CGRectMake(20.0, 11.0, 22.0, 22.0)];
    [settingsButton addTarget:self action:@selector(favoriteBarButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [settingsButton setImage:settingsImage forState:UIControlStateNormal];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:settingsButton];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
 /*   [DataInstance getInstance].latitude = @"12.873571";
    [DataInstance getInstance].longitude = @"77.570768";
	
	[DataInstance getInstance].latitude = @"-33.8670522";
	[DataInstance getInstance].longitude = @"151.1957362";
	
	[[NSUserDefaults standardUserDefaults] setObject:@"-33.8670522" forKey:@"latitude"];
	[[NSUserDefaults standardUserDefaults] setObject:@"151.1957362" forKey:@"longitude"];
	[[NSUserDefaults standardUserDefaults] synchronize];
*/
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"latitude"] != nil)
	{
		[DataInstance getInstance].latitude = [[NSUserDefaults standardUserDefaults] objectForKey:@"latitude"];
		[DataInstance getInstance].longitude = [[NSUserDefaults standardUserDefaults] objectForKey:@"longitude"];
	}
	
	// Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
	if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
	{
		[locationManager requestWhenInUseAuthorization];
	}
	
	[locationManager startUpdatingLocation];
}

- (void)didReceiveMemoryWarning {
	
    [super didReceiveMemoryWarning];
}


#pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	PlaceTypeTVCell *cell = (PlaceTypeTVCell *)[tableView dequeueReusableCellWithIdentifier:@"typeCell"];
	if (cell == nil)
	{
		[tableView registerNib:[UINib nibWithNibName:@"PlaceTypeTVCell" bundle:nil] forCellReuseIdentifier:@"typeCell"];
		cell = (PlaceTypeTVCell *)[tableView dequeueReusableCellWithIdentifier:@"typeCell"];
	}

	cell.backgroundColor = [UIColor whiteColor];
	switch (indexPath.row)
	{
		case 0:
		{
			cell.placeTypeNameLabel.text = @"Food";
			cell.placeTypeImageView.image = [UIImage imageNamed:@"iconFood.png"];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
			break;
		case 1:
		{
			cell.placeTypeNameLabel.text = @"Gym";
			cell.placeTypeImageView.image = [UIImage imageNamed:@"iconGym.png"];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
			break;
		case 2:
		{
			cell.placeTypeNameLabel.text = @"School";
			cell.placeTypeImageView.image = [UIImage imageNamed:@"iconSchool.png"];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
			break;
		case 3:
		{
			cell.placeTypeNameLabel.text = @"Hospital";
			cell.placeTypeImageView.image = [UIImage imageNamed:@"iconHospital.png"];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
			break;
		case 4:
		{
			cell.placeTypeNameLabel.text = @"Spa";
			cell.placeTypeImageView.image = [UIImage imageNamed:@"iconSpa.png"];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
			break;
		case 5:
		{
			cell.placeTypeNameLabel.text = @"­Restaurant";
			cell.placeTypeImageView.image = [UIImage imageNamed:@"iconRestaurant.png"];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
			break;

		default:
			break;
	}
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	return 60.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	
	return 30.0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// Remove seperator inset
	if ([cell respondsToSelector:@selector(setSeparatorInset:)])
	{
		[cell setSeparatorInset:UIEdgeInsetsZero];
	}
	
	// Prevent the cell from inheriting the Table View's margin settings
	if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)])
	{
		[cell setPreservesSuperviewLayoutMargins:NO];
	}
	
	// Explictly set your cell's layout margins
	if ([cell respondsToSelector:@selector(setLayoutMargins:)])
	{
		[cell setLayoutMargins:UIEdgeInsetsZero];
	}
}


#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString *placeType;
    NSString *headingName;
	switch (indexPath.row)
	{
		case 0:
		{
			placeType = @"food";
            headingName = @"Food";
		}
			break;
		case 1:
		{
			placeType = @"gym";
            headingName = @"Gym";
		}
			break;
		case 2:
		{
			placeType = @"school";
            headingName = @"School";
		}
			break;
		case 3:
		{
			placeType = @"hospital";
            headingName = @"Hospital";
		}
			break;
		case 4:
		{
			placeType = @"spa";
            headingName = @"Spa";
		}
			break;
		case 5:
		{
			placeType = @"restaurant";
            headingName = @"Restaurant";
		}
			break;
			
		default:
			break;
	}

	PlaceListViewController *vcPlaceList = [[PlaceListViewController alloc] initWithNibName:@"PlaceListViewController" bundle:nil];
    vcPlaceList.placeType = placeType;
    vcPlaceList.headingName = headingName;
    [self.navigationController pushViewController:vcPlaceList animated:YES];
	
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Location info will help us to find near by places. Please enable location permission from your settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
    [locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *currentLocation = [locations lastObject];
    
    [locationManager stopUpdatingLocation];
    
    NSString *latitude = [NSString stringWithFormat:@"%.6f", currentLocation.coordinate.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%.6f", currentLocation.coordinate.longitude];
    
    [DataInstance getInstance].latitude = latitude;
    [DataInstance getInstance].longitude = longitude;
    
	[[NSUserDefaults standardUserDefaults] setObject:latitude forKey:@"latitude"];
	[[NSUserDefaults standardUserDefaults] setObject:longitude forKey:@"longitude"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
    NSLog(@"%@", currentLocation);
    
    [locationManager stopUpdatingLocation];
}


#pragma mark - Action Methods

- (void)favoriteBarButtonPressed:(id)sender {
    
    SettingsViewController *vcSettings = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:[NSBundle bundleForClass:[self class]]];
    [self.navigationController pushViewController:vcSettings animated:YES];
}

@end
