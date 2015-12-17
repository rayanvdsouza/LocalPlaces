//
//  MapViewController.m
//  LocalPlaces
//
//  Created by Rayan on 17/12/15.
//  Copyright © 2015 Rayan. All rights reserved
//

#import "MapViewController.h"

#import <MapKit/MapKit.h>

@interface MapViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *placeMapView;

@end

@implementation MapViewController

#pragma mark - UIViewController Events

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    CLLocationCoordinate2D myCoordinate;
    myCoordinate.latitude = self.latitude;
    myCoordinate.longitude = self.longitude;
    annotation.coordinate = myCoordinate;
    [self.placeMapView addAnnotation:annotation];
	
	MKCoordinateRegion region;
	region.center.latitude = myCoordinate.latitude;
	region.center.longitude = myCoordinate.longitude;
	region.span.latitudeDelta = 0.005;
	region.span.longitudeDelta = 0.005;
	
	[self.placeMapView setRegion:region animated:YES];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}


@end
