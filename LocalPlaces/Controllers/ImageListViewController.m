//
//  ImageListViewController.m
//  LocalPlaces
//
//  Created by Rayan on 17/12/15.
//  Copyright © 2015 Rayan. All rights reserved
//

#import "ImageListViewController.h"

#import "Photo.h"
#import "ServerAPI.h"
#import "ImagePageViewController.h"
#import "FeedCollectionViewCell.h"


@interface ImageListViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *feedsCollectionView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (nonatomic, strong) NSMutableArray *photoList;
@property (nonatomic) BOOL getPhotosNextLock;

@end

@implementation ImageListViewController

#pragma mark - UIViewController Events

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
	titleLabel.text = @"Photos";
    titleLabel.textColor = APP_TITLE_FONT_COLOR;
    titleLabel.font = APP_TITLE_FONT;
    self.navigationItem.titleView = titleLabel;
	
    self.photoList = [[NSMutableArray alloc] initWithArray:self.photos];

	self.refreshControl = [[UIRefreshControl alloc] init];
	[self.refreshControl addTarget:self action:@selector(refreshControlShouldRefresh) forControlEvents:UIControlEventValueChanged];
	[self.feedsCollectionView addSubview:self.refreshControl];
	
	[self.feedsCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"activityIndicatorCell"];

    [self.feedsCollectionView registerNib:[UINib nibWithNibName:@"FeedCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"feedImageCell"];

	self.feedsCollectionView.dataSource = self;
	self.feedsCollectionView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
	
	[self.feedsCollectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}


#pragma mark - UICollectionView Datasource

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
	
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
	
    return self.photoList.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	
	Photo *objPhoto = self.photoList[indexPath.item];
	
    FeedCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"feedImageCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
	
	NSString *imageUrl = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=%@&key=%@",objPhoto.photoReference,GOOGLE_MAP_KEY];

	UIImage *placeImage = [[DataInstance getInstance].globalDictionaryCache objectForKey:imageUrl];
	
	if (placeImage == nil)
	{
		dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
		dispatch_async(queue, ^{
			
			NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
			UIImage *image = [UIImage imageWithData:data];
			[[DataInstance getInstance].globalDictionaryCache setObject:image forKey:imageUrl];
			dispatch_async(dispatch_get_main_queue(), ^{
				
				cell.feedImage.image = image;
			});
		});
	}
	else
	{
		cell.feedImage.image = placeImage;
	}

    return cell;
}


#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
	ImagePageViewController *vcImagePage = [[ImagePageViewController alloc] initWithNibName:@"ImagePageViewController" bundle:nil];
    vcImagePage.currentIndex = indexPath.item;
    vcImagePage.pageFeedsList = self.photoList;
	[self.navigationController presentViewController:vcImagePage animated:NO completion:nil];
}


#pragma mark UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
	
    return CGSizeMake(0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
	
	return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
	
	return 2.0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
	
	return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	
	CGFloat width = ((collectionView.frame.size.width + 2) / 3) - 2;
	return CGSizeMake(width, width);
}

@end
