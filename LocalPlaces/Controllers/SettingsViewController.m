//
//  SettingsViewController.m
//  LocalPlaces
//
//  Created by Rayan on 17/12/15.
//  Copyright © 2015 Rayan. All rights reserved
//

#import "SettingsViewController.h"


#import <CoreLocation/CoreLocation.h>

@interface SettingsViewController () <CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UITextField *radiusTextField;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

- (IBAction)saveButtonPressed:(id)sender;

@end

@implementation SettingsViewController {
	
	CLLocationManager *locationManager;
}


#pragma mark - UIViewController Events

- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
	titleLabel.text = @"Settings";
	titleLabel.textColor = APP_TITLE_FONT_COLOR;
	titleLabel.font = APP_TITLE_FONT;
	self.navigationItem.titleView = titleLabel;
	
	if ([[NSUserDefaults standardUserDefaults] integerForKey:@"searchRadius"] <= 0)
	{
		[[NSUserDefaults standardUserDefaults] setInteger:1000 forKey:@"searchRadius"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	
	NSInteger radius = [[NSUserDefaults standardUserDefaults] integerForKey:@"searchRadius"];
	
	self.radiusTextField.text = [NSString stringWithFormat:@"%ld",radius];
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"latitude"] == nil)
	{
		self.locationLabel.text = @"Location not found";
	}
	else
	{
		[DataInstance getInstance].latitude = [[NSUserDefaults standardUserDefaults] objectForKey:@"latitude"];
		[DataInstance getInstance].longitude = [[NSUserDefaults standardUserDefaults] objectForKey:@"longitude"];
		
		self.locationLabel.text = [NSString stringWithFormat:@"%@, %@",[DataInstance getInstance].latitude, [DataInstance getInstance].longitude];
	}
	
	
	
	// Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
	if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
	{
		[locationManager requestWhenInUseAuthorization];
	}
	
	[locationManager startUpdatingLocation];
	
	self.saveButton.layer.cornerRadius = self.saveButton.frame.size.height / 2;
	self.saveButton.layer.masksToBounds = YES;
	
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
	[self.view addGestureRecognizer:tap];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    CGRect frame;
    frame = self.saveButton.frame;
    frame.origin.x = (self.view.frame.size.width - self.saveButton.frame.size.width) / 2;
    self.saveButton.frame = frame;
}

- (void)viewDidAppear:(BOOL)animated {
	
	[super viewDidAppear:animated];
	
	CGRect frame;
	frame = self.saveButton.frame;
	frame.origin.x = (self.view.frame.size.width - self.saveButton.frame.size.width) / 2;
	self.saveButton.frame = frame;
}

- (void)didReceiveMemoryWarning {
	
    [super didReceiveMemoryWarning];
}

- (void)dismissKeyboard {
	
	[self.view endEditing:YES];
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	
	NSLog(@"didFailWithError: %@", error);
	UIAlertView *errorAlert = [[UIAlertView alloc]
							   initWithTitle:@"Error" message:@"Location info will help us to find near by places. Please enable location permission from your settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[errorAlert show];
	[locationManager stopUpdatingLocation];
	
	// [DataInstance getInstance].latitude = @"";
	//[DataInstance getInstance].longitude = @"";
	
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
	
	self.locationLabel.text = [NSString stringWithFormat:@"%@, %@",[DataInstance getInstance].latitude, [DataInstance getInstance].longitude];
	
	NSLog(@"%@", currentLocation);
	
	[locationManager stopUpdatingLocation];
}


#pragma mark - Action Methods

- (IBAction)saveButtonPressed:(id)sender {
    
    NSInteger radius = [self.radiusTextField.text integerValue];
    
    if (radius <= 0)
    {
        radius = 1000;
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger:radius forKey:@"searchRadius"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.radiusTextField.text = [NSString stringWithFormat:@"%ld",radius];
    
    [self.view endEditing:YES];
}

@end
