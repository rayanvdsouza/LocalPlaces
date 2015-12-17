//
//  ImagePageViewController.m
//  LocalPlaces
//
//  Created by Rayan on 17/12/15.
//  Copyright © 2015 Rayan. All rights reserved
//

#import "ImagePageViewController.h"

#import "Photo.h"
#import "AppDelegate.h"
#import "FullImageViewController.h"


@interface ImagePageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIView *pageContainerView;
@property (strong, nonatomic) UIPageViewController *pageController;

@property (strong, nonatomic) NSMutableArray *viewControllerArray;

- (IBAction)doneButtonClicked:(id)sender;

@end

@implementation ImagePageViewController

- (BOOL)hidesBottomBarWhenPushed {
	
	return YES;
}

- (BOOL)prefersStatusBarHidden {
	
	return YES;
}


#pragma mark - ViewController Events

- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]
										  initWithTarget:self action:@selector(showHideNavbar:)];
	[self.view addGestureRecognizer:tapGesture];
	
	self.navigationController.navigationBar.translucent = YES;
	[self.navigationController setNavigationBarHidden:YES animated:YES];
	
	self.edgesForExtendedLayout = UIRectEdgeAll;
	
	self.viewControllerArray = [[NSMutableArray alloc] init];
	for (int i = 0; i < self.pageFeedsList.count; i++)
	{
		[self.viewControllerArray addObject:[self viewControllerAtIndex:i]];
	}
	
	UIPageControl *pageControl = [UIPageControl appearance];
	pageControl.pageIndicatorTintColor = [UIColor colorWithRed:183/255.0 green:219/255.0 blue:248/255.0 alpha:1.0];
	pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:0/255.0 green:126/255.0 blue:229/255.0 alpha:1.0];
	
	self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
	self.pageController.dataSource = self;
	self.pageController.delegate = self;
	self.parentViewController.view.backgroundColor = [UIColor blackColor];
	
	CGRect frame = [self.view bounds];
	[self.pageController.view setFrame:frame];
		
	NSArray *viewControllers = [NSArray arrayWithObject:[self viewControllerAtIndex:self.currentIndex]];

	[self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
	
	[self addChildViewController:self.pageController];
	[self.pageContainerView addSubview:self.pageController.view];
	[self.pageController didMoveToParentViewController:self];
}

- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
	
	[self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillLayoutSubviews {
	
	[super viewWillLayoutSubviews];
}

- (void)didReceiveMemoryWarning {
	
    [super didReceiveMemoryWarning];
}


#pragma mark - UIPageViewControllerDataSource implementation

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
	
	NSUInteger index = [(FullImageViewController *)viewController pageIndex];

	if (index == 0)
	{
		return nil;
	}
	return [self viewControllerAtIndex:(index - 1)];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
	
	NSUInteger index = [(FullImageViewController *)viewController pageIndex];

	if (index == self.pageFeedsList.count - 1)
	{
		return nil;
	}
	return [self viewControllerAtIndex:(index + 1)];
}

- (IBAction)doneButtonClicked:(id)sender {
	
	[self dismissViewControllerAnimated:NO completion:nil];
}


#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
	
}


#pragma mark - Private Methods

-(void) showHideNavbar:(id) sender {
    
	if (self.doneButton.hidden == YES)
	{
		self.doneButton.hidden = NO;
		self.doneButton.alpha = 0.0;

		[UIView animateWithDuration:0.5 animations:^{
			
			self.doneButton.alpha = 1.0;
			
		} completion:^(BOOL finished) {
			
			self.doneButton.hidden = NO;
		}];
	}
	else
	{
		self.doneButton.hidden = NO;
		self.doneButton.alpha = 1.0;

		[UIView animateWithDuration:0.5 animations:^{
			
			self.doneButton.alpha = 0.0;
			
		} completion:^(BOOL finished) {
			
			self.doneButton.hidden = YES;
		}];
	}
}

- (FullImageViewController *)viewControllerAtIndex:(NSUInteger)index {
		
	FullImageViewController *childViewController = [[FullImageViewController alloc] initWithNibName:@"FullImageViewController" bundle:nil];
	childViewController.pageIndex = index;
    
    Photo *objPhoto = self.pageFeedsList[index];
    
    NSString *imageUrl = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=%@&key=%@",objPhoto.photoReference,GOOGLE_MAP_KEY];
    childViewController.imageUrl = imageUrl;
	return childViewController;
}

@end
