//
//  PlaceListViewController.m
//  CustomTableView
//
//  Created by Rayan on 17/12/15.
//  Copyright © 2015 Rayan. All rights reserved
//

#import "PlaceListViewController.h"

#import "ServerAPI.h"
#import "Place.h"
#import "Photo.h"
#import "PlaceDetailViewController.h"
#import "PlaceTVCell.h"

#import <CoreData/CoreData.h>

@interface PlaceListViewController () <UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *placeTableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *placeSegmentControl;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) NSMutableArray *placesList;
@property (strong, nonatomic) NSMutableArray *favoritePlacesList;
@property (nonatomic) BOOL getFetchRecordsLock;
@property (copy, nonatomic) NSString *nextPageToken;

- (IBAction)placeSegmentControlValueChange:(id)sender;

@end

@implementation PlaceListViewController

- (NSManagedObjectContext *)managedObjectContext {
    
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)])
    {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (void)viewDidLoad {
	
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.translucent = NO;
    //self.view.backgroundColor = APP_BACKGROUD_COLOR;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    titleLabel.text = self.headingName;
    titleLabel.textColor = APP_TITLE_FONT_COLOR;
    titleLabel.font = APP_TITLE_FONT;
    self.navigationItem.titleView = titleLabel;
    
    self.getFetchRecordsLock = NO;
    self.placesList = [[NSMutableArray alloc] init];
    self.favoritePlacesList = [[NSMutableArray alloc] init];
    
    self.placeTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.placeTableView.delegate = self;
    self.placeTableView.dataSource = self;
	self.placeTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.placeTableView.contentInset = UIEdgeInsetsMake(0, 0, 10, 0);
	
	self.refreshControl = [[UIRefreshControl alloc] init];
	[self.refreshControl addTarget:self action:@selector(refreshControlShouldRefresh) forControlEvents:UIControlEventValueChanged];
	[self.placeTableView addSubview:self.refreshControl];
	
	self.placeSegmentControl.tintColor = APP_BACKGROUD_COLOR;

}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if(self.placesList.count == 0)
    {
        [self getFeedsFromMap:self.nextPageToken];
    }
	
	if (self.placeSegmentControl.selectedSegmentIndex == 1)
	{
		NSArray *favoriteArray = [self getFavoritePlaces];
		[self.favoritePlacesList removeAllObjects];
		[self.favoritePlacesList addObjectsFromArray:favoriteArray];
		[self.refreshControl endRefreshing];
		[self.placeTableView reloadData];
	}
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (self.placeSegmentControl.selectedSegmentIndex == 0)
    {
        float bottomEdge = scrollView.contentSize.height - scrollView.frame.size.height - 50;
        
        if(scrollView.contentOffset.y >= bottomEdge && self.getFetchRecordsLock == NO && self.nextPageToken != nil)
        {
            [self getFeedsFromMap:self.nextPageToken];
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
	if (self.placeSegmentControl.selectedSegmentIndex == 0)
	{
		if(self.nextPageToken != nil)
		{
			return self.placesList.count + 1;
		}
		return self.placesList.count;
	}
	return self.favoritePlacesList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.placeSegmentControl.selectedSegmentIndex == 0)
    {
        if(self.placesList.count == indexPath.row)
        {
            return 50;
        }
        return 70;
    }
    return 70;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	
	return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 10)];
	headerView.backgroundColor = [UIColor clearColor];
	
	return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.placeSegmentControl.selectedSegmentIndex == 0)
    {
        if(self.placesList.count == indexPath.section)
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"activityCell"];
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"activityCell"];
            }
            
            cell.backgroundColor = [UIColor clearColor];
            CGRect bounds = cell.bounds;
            bounds.size.width = tableView.frame.size.width;
            UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:bounds];
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
            [cell addSubview:activityIndicator];
            [activityIndicator startAnimating];
            return cell;
        }
    }
    
    PlaceTVCell *cell = (PlaceTVCell *)[tableView dequeueReusableCellWithIdentifier:@"placeCell"];
    if (cell == nil)
    {
        [tableView registerNib:[UINib nibWithNibName:@"PlaceTVCell" bundle:nil] forCellReuseIdentifier:@"placeCell"];
        cell = (PlaceTVCell *)[tableView dequeueReusableCellWithIdentifier:@"placeCell"];
    }
	
	cell.layer.cornerRadius = 5.0;
	cell.layer.masksToBounds = YES;
    
    Place *objPlace;
    if (self.placeSegmentControl.selectedSegmentIndex == 0)
    {
        objPlace = self.placesList[indexPath.section];
    }
    else
    {
        objPlace = self.favoritePlacesList[indexPath.section];
    }
	
	NSLog(@"Photos Count %ld:%ld",indexPath.row, objPlace.photos.count);
	
	NSString *photoRef = nil;
	if (objPlace.photos.count > 0)
	{
		Photo *photo = objPlace.photos[0];
		photoRef = photo.photoReference;
	}
	
	NSString *imageUrl = objPlace.icon;

	if (photoRef != nil)
	{
		imageUrl = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=%@&key=%@",photoRef,GOOGLE_MAP_KEY];
	}

	cell.thumbnailImageView.layer.cornerRadius = 3.0;
	cell.thumbnailImageView.layer.masksToBounds = YES;
	
    cell.nameLabel.text = objPlace.name;
    //[cell.thumbnailImageView setImageWithURL:[NSURL URLWithString:objPlace.icon] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];

    
    //NSDictionary *cache = [DataInstance getInstance].globalDictionaryCache;
    
    UIImage *placeImage = [[DataInstance getInstance].globalDictionaryCache objectForKey:imageUrl];
    
    if (placeImage == nil)
    {
        cell.imageView.image = [UIImage imageNamed:@"placeholder.png"];
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^{
            
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
            UIImage *image = [UIImage imageWithData:data];
            [[DataInstance getInstance].globalDictionaryCache setObject:image forKey:imageUrl];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                cell.thumbnailImageView.image = image;
            });
        });
    }
    else
    {
        cell.thumbnailImageView.image = placeImage;
    }
    
    
    return cell;
}


#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.placeSegmentControl.selectedSegmentIndex == 0)
    {
        if(self.placesList.count == indexPath.row)
        {
            return;
        }
    }
    
    Place *objPlace;
    if (self.placeSegmentControl.selectedSegmentIndex == 0)
    {
        objPlace = self.placesList[indexPath.section];
    }
    else
    {
        objPlace = self.favoritePlacesList[indexPath.section];
    }
    
    PlaceDetailViewController *vcPlaceDetail = [[PlaceDetailViewController alloc] initWithNibName:@"PlaceDetailViewController" bundle:nil];
    vcPlaceDetail.place = objPlace;
    [self.navigationController pushViewController:vcPlaceDetail animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


#pragma mark - UIRefreshControl

- (void)refreshControlShouldRefresh {
	
	if (self.placeSegmentControl.selectedSegmentIndex == 0)
	{
		[self getFeedsFromMap:nil];
	}
	else
	{
		NSArray *favoriteArray = [self getFavoritePlaces];
		[self.favoritePlacesList removeAllObjects];
		[self.favoritePlacesList addObjectsFromArray:favoriteArray];
		[self.refreshControl endRefreshing];
	}
	[self.placeTableView reloadData];
}

#pragma mark - Private Methods

- (void)getFeedsFromMap:(NSString *)pageToken {
	
    self.getFetchRecordsLock = YES;
    
    NSString *latitude = [DataInstance getInstance].latitude;
    NSString *longitude = [DataInstance getInstance].longitude;
	
	NSInteger radius = [[NSUserDefaults standardUserDefaults] integerForKey:@"searchRadius"];
	if (radius <= 0)
	{
		radius = 1000;
	}
    
    [ServerAPI getNearByPlacesInLocation:latitude longitude:longitude radius:radius type:self.placeType pageToken:pageToken completion:^(NSArray *objects, NSString *nextPageToken, NSError *error) {
        
        if (error == nil)
        {
            if (self.nextPageToken == nil)
            {
                [self.placesList removeAllObjects];
            }
            self.nextPageToken = nextPageToken;
            
            [self.placesList addObjectsFromArray:[objects copy]];
			
			
            [self.placeTableView reloadData];
        }
        //[mbProgressIndicator hide:YES];
        [self.refreshControl endRefreshing];
        self.getFetchRecordsLock = NO;
    }];
    
}


- (IBAction)placeSegmentControlValueChange:(id)sender {

    if (self.placeSegmentControl.selectedSegmentIndex == 0)
    {
        if(self.placesList.count == 0)
        {
			[self getFeedsFromMap:self.nextPageToken];
        }
    }
    else
    {
        NSArray *favoriteArray = [self getFavoritePlaces];
        [self.favoritePlacesList removeAllObjects];
        [self.favoritePlacesList addObjectsFromArray:favoriteArray];
    }
    [self.placeTableView reloadData];
}

- (NSArray *)getFavoritePlaces {
    
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Favorites" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"type == %@", self.placeType];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchResults = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    NSMutableArray *favoriteArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < fetchResults.count; i++)
    {
        NSManagedObject *managedPlace = [fetchResults objectAtIndex:i];
        
        Place *object = [[Place alloc] init];
        object.placeId = [managedPlace valueForKey:@"placeId"];
        object.name = [managedPlace valueForKey:@"placeName"];
        object.icon = [managedPlace valueForKey:@"placeImage"];
        object.type = [managedPlace valueForKey:@"type"];
        [favoriteArray addObject:object];
    }
    
    return favoriteArray;
    
    
}


@end
