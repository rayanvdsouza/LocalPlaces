//
//  PlaceDetailViewController.m
//  LocalPlaces
//
//  Created by Rayan on 17/12/15.
//  Copyright © 2015 Rayan. All rights reserved
//

#import "PlaceDetailViewController.h"

#import "Place.h"
#import "Photo.h"
#import "MapViewController.h"
#import "ImageListViewController.h"
#import "ServerAPI.h"

#import <CoreData/CoreData.h>

@interface PlaceDetailViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *placeImageView;
@property (weak, nonatomic) IBOutlet UILabel *placeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeVicinityLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeAddressHeadingLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeAddressLabel;
@property (weak, nonatomic) IBOutlet UIView *placeNameContainerView;
@property (weak, nonatomic) IBOutlet UIView *placeOptionsContainerView;
@property (weak, nonatomic) IBOutlet UIScrollView *containerScrollView;
@property (weak, nonatomic) IBOutlet UIButton *morePhotosButton;
@property (weak, nonatomic) IBOutlet UIView *moreImagesButtonConainerView;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) NSString *placeType;
@property (nonatomic) BOOL isFavorite;
@property (strong, nonatomic) NSArray *photosList;

- (IBAction)favoriteButtonClicked:(id)sender;
- (IBAction)viewInMapButtonPressed:(id)sender;
- (IBAction)morePhotosButtonPressed:(id)sender;

@end

@implementation PlaceDetailViewController

- (NSManagedObjectContext *)managedObjectContext {
    
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)])
    {
        context = [delegate managedObjectContext];
    }
    return context;
}


#pragma mark - UIViewController Events

- (void)viewDidLoad {
    
    [super viewDidLoad];
	
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
	titleLabel.text = @"Place Details";
	titleLabel.textColor = APP_TITLE_FONT_COLOR;
	titleLabel.font = APP_TITLE_FONT;
	self.navigationItem.titleView = titleLabel;
	
	self.placeType = self.place.type;
	
	self.isFavorite = [self checkIsFavoritePlace:self.place.placeId];
 
	self.morePhotosButton.hidden = YES;
	[ServerAPI getPlaceDetails:self.place.placeId completion:^(Place *object, NSError *error) {
		
		if (!error)
		{
			self.photosList = object.photos;
			
			if (self.photosList > 0)
			{
				self.morePhotosButton.hidden = NO;
			}
			
			self.place = object;
			self.place.type = self.placeType;
			[self updateUI];
		}
	}];
}

- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
	[self updateUI];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}


#pragma mark - Action Methods

- (IBAction)favoriteButtonClicked:(id)sender {

	self.isFavorite = !self.isFavorite;
	if (self.isFavorite == YES)
	{
		[self addFavoritePlace:self.place];
		[self.favoriteButton setImage:[UIImage imageNamed:@"iconFavoriteSelected.png"] forState:UIControlStateNormal];
	}
	else
	{
		[self removeFavoritePlace:self.place.placeId];
		[self.favoriteButton setImage:[UIImage imageNamed:@"iconFavoriteUnselected.png"] forState:UIControlStateNormal];
	}
}

- (IBAction)viewInMapButtonPressed:(id)sender {

    MapViewController *vcMap = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:[NSBundle bundleForClass:[self class]]];
    vcMap.latitude = self.place.latitude;
    vcMap.longitude = self.place.longitude;
    [self.navigationController pushViewController:vcMap animated:YES];
}

- (IBAction)morePhotosButtonPressed:(id)sender {
	
	ImageListViewController *vcImageList = [[ImageListViewController alloc] initWithNibName:@"ImageListViewController" bundle:[NSBundle bundleForClass:[self class]]];
	vcImageList.photos = self.photosList;
	[self.navigationController pushViewController:vcImageList animated:YES];
}


#pragma mark - Private Methods

- (void)updateUI {
	
	self.placeNameLabel.text = self.place.name;
	self.placeVicinityLabel.text = self.place.vicinity;
	
	CGRect frame;
	
	self.placeNameLabel.numberOfLines = 0;
	CGSize size = [self.placeNameLabel sizeThatFits:CGSizeMake(self.view.frame.size.width - 20, 10)];
	frame = self.placeNameLabel.frame;
	frame.size.height = size.height;
	self.placeNameLabel.frame = frame;
	
	self.placeVicinityLabel.numberOfLines = 0;
	size = [self.placeVicinityLabel sizeThatFits:CGSizeMake(self.view.frame.size.width - 20, 10)];
	frame = self.placeVicinityLabel.frame;
	frame.origin.y = self.placeNameLabel.frame.origin.y + self.placeNameLabel.frame.size.height + 5;
	frame.size.height = size.height;
	self.placeVicinityLabel.frame = frame;
	
	frame = self.placeNameContainerView.frame;
	frame.size.height = self.placeVicinityLabel.frame.origin.y + self.placeVicinityLabel.frame.size.height + 10;
	self.placeNameContainerView.frame = frame;
	
	frame = self.placeOptionsContainerView.frame;
	frame.origin.y = self.placeNameContainerView.frame.origin.y + self.placeNameContainerView.frame.size.height;
	self.placeOptionsContainerView.frame = frame;
	
	if (self.place.address == nil)
	{
		self.placeAddressHeadingLabel.hidden = YES;
		self.placeAddressLabel.hidden = YES;
		
		self.containerScrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.placeOptionsContainerView.frame.origin.y + self.placeOptionsContainerView.frame.size.height + 20);
	}
	else
	{
		self.placeAddressHeadingLabel.hidden = NO;
		self.placeAddressLabel.hidden = NO;
		
		self.placeAddressLabel.text = self.place.address;
        self.placeAddressLabel.numberOfLines = 0;
		
		frame = self.placeAddressHeadingLabel.frame;
		frame.origin.y = self.placeOptionsContainerView.frame.origin.y + self.placeOptionsContainerView.frame.size.height + 10;
		self.placeAddressHeadingLabel.frame = frame;
		
		size = [self.placeAddressLabel sizeThatFits:CGSizeMake(self.view.frame.size.width - 20, 10)];
		frame = self.placeAddressLabel.frame;
		frame.origin.y = self.placeAddressHeadingLabel.frame.origin.y + self.placeAddressHeadingLabel.frame.size.height + 10;
		frame.size.height = size.height;
		self.placeAddressLabel.frame = frame;

		self.containerScrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.placeAddressLabel.frame.origin.y + self.placeAddressLabel.frame.size.height + 20);
	}
	
	if ([self checkIsFavoritePlace:self.place.placeId] == YES)
	{
		[self.favoriteButton setImage:[UIImage imageNamed:@"iconFavoriteSelected.png"] forState:UIControlStateNormal];
	}
	else
	{
		[self.favoriteButton setImage:[UIImage imageNamed:@"iconFavoriteUnselected.png"] forState:UIControlStateNormal];
	}
	
	NSString *photoRef;
	if (self.place.photos.count > 0)
	{
		Photo *photo = self.place.photos[0];
		photoRef = photo.photoReference;
	}
	
	NSString *imageUrl = nil;
	
	if (photoRef != nil)
	{
		imageUrl = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=%@&key=%@",photoRef,GOOGLE_MAP_KEY];
	}
	
	if (imageUrl != nil)
	{
		UIImage *placeImage = [[DataInstance getInstance].globalDictionaryCache objectForKey:imageUrl];
		
		if (placeImage == nil)
		{
			dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
			dispatch_async(queue, ^{
				
				NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
				UIImage *image = [UIImage imageWithData:data];
				[[DataInstance getInstance].globalDictionaryCache setObject:image forKey:imageUrl];
				dispatch_async(dispatch_get_main_queue(), ^{
					
					self.placeImageView.image = image;
				});
			});
		}
		else
		{
			self.placeImageView.image = placeImage;
		}
	}
	
	self.moreImagesButtonConainerView.layer.cornerRadius = self.moreImagesButtonConainerView.frame.size.width / 2;
	self.moreImagesButtonConainerView.layer.masksToBounds = YES;
	
	if (self.place.photos.count > 1)
	{
		self.moreImagesButtonConainerView.hidden = NO;
	}
	else
	{
		self.moreImagesButtonConainerView.hidden = YES;
	}
}

- (void)addFavoritePlace:(Place *)place {
	
	NSManagedObjectContext *context = [self managedObjectContext];
	
	NSString *photoRef;
	if (place.photos.count > 0)
	{
		Photo *photo = place.photos[0];
		photoRef = photo.photoReference;
	}
	
	NSString *imageUrl = place.icon;
	
	if (photoRef != nil)
	{
		imageUrl = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=%@&key=%@",photoRef,GOOGLE_MAP_KEY];
	}
	
	// Create a new managed object
	NSManagedObject *favPlace = [NSEntityDescription insertNewObjectForEntityForName:@"Favorites" inManagedObjectContext:context];
	[favPlace setValue:place.placeId forKey:@"placeId"];
	[favPlace setValue:place.name forKey:@"placeName"];
	[favPlace setValue:imageUrl forKey:@"placeImage"];
	[favPlace setValue:place.type forKey:@"type"];
	
	NSError *error = nil;
	// Save the object to persistent store
	if (![context save:&error])
	{
		NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
	}
}

- (void)removeFavoritePlace:(NSString *)placeId {
	
	NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Favorites" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat: @"placeId == %@", placeId];
	[fetchRequest setPredicate:predicate];
	
	NSError *error = nil;
	NSArray *fetchResults = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	
	if (!error && fetchResults.count > 0)
	{
		for(NSManagedObject *managedObject in fetchResults)
		{
			[managedObjectContext deleteObject:managedObject];
		}
		
		//Save context to write to store
		[managedObjectContext save:nil];
	}
}

- (BOOL)checkIsFavoritePlace:(NSString *)placeId {
	
	NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Favorites" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"placeId == %@", placeId];
	[fetchRequest setPredicate:predicate];
	
	NSError *error = nil;
	NSArray *fetchResults = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	
	if (fetchResults.count > 0)
	{
		return YES;
	}
	return NO;
}

@end
