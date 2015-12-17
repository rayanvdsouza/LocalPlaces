//
//  FullImageViewController.m
//  LocalPlaces
//
//  Created by Rayan on 17/12/15.
//  Copyright © 2015 Rayan. All rights reserved
//

#import "FullImageViewController.h"

@interface FullImageViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *fullImageView;
@property (weak, nonatomic) IBOutlet UIScrollView *imageScrollView;

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@end

@implementation FullImageViewController

- (BOOL)hidesBottomBarWhenPushed {
	
	return YES;
}

#pragma mark - UIViewController Events

- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	CGRect screenRect = [[UIScreen mainScreen] bounds];
	self.activityIndicator.frame = CGRectMake((screenRect.size.width - 25) / 2, (screenRect.size.height - 100) / 2, 25, 25);
	[self.view addSubview:self.activityIndicator];
	[self.activityIndicator startAnimating];
    
    if (self.imageUrl != nil)
    {
        UIImage *placeImage = [[DataInstance getInstance].globalDictionaryCache objectForKey:self.imageUrl];
        
        if (placeImage == nil)
        {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
            dispatch_async(queue, ^{
                
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.imageUrl]];
                UIImage *image = [UIImage imageWithData:data];
                [[DataInstance getInstance].globalDictionaryCache setObject:image forKey:self.imageUrl];
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    self.fullImageView.image = image;
                    [self.activityIndicator stopAnimating];
                });
            });
        }
        else
        {
            self.fullImageView.image = placeImage;
            [self.activityIndicator stopAnimating];
        }
    }
}


- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
	
	CGSize screenSize = [UIScreen mainScreen].bounds.size;

	if (screenSize.height > screenSize.width)
	{
		self.fullImageView.frame = CGRectMake(0, (screenSize.height - screenSize.width) / 2, screenSize.width, screenSize.width);
	}
	else
	{
		self.fullImageView.frame = CGRectMake((screenSize.width - screenSize.height) / 2, 0, screenSize.height, screenSize.height);
	}

	self.imageScrollView.contentSize = self.fullImageView.frame.size;
	
	self.imageScrollView.delegate = self;
	self.imageScrollView.minimumZoomScale = 1.0;
	self.imageScrollView.maximumZoomScale = 100.0;
	
	self.imageScrollView.zoomScale = 1.0;
}

- (void)viewWillLayoutSubviews {
	
	[super viewWillLayoutSubviews];
	
	CGSize screenSize = [UIScreen mainScreen].bounds.size;
	
	if (screenSize.height > screenSize.width)
	{
		self.fullImageView.frame = CGRectMake(0, (screenSize.height - screenSize.width) / 2, screenSize.width, screenSize.width);
	}
	else
	{
		self.fullImageView.frame = CGRectMake((screenSize.width - screenSize.height) / 2, 0, screenSize.height, screenSize.height);
	}
	
	self.imageScrollView.contentSize = self.fullImageView.frame.size;
	
	self.imageScrollView.delegate = self;
	self.imageScrollView.minimumZoomScale = 1.0;
	self.imageScrollView.maximumZoomScale = 100.0;
	
	self.imageScrollView.zoomScale = 1.0;
}

- (void)didReceiveMemoryWarning {
	
    [super didReceiveMemoryWarning];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	
	return self.fullImageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
	
	UIView *zoomView = [scrollView.delegate viewForZoomingInScrollView:scrollView];
	
	CGRect frame = zoomView.frame;
	if(frame.size.width < scrollView.bounds.size.width)
	{
		frame.origin.x = (scrollView.bounds.size.width - frame.size.width) / 2.0;
	}
	else
	{
		frame.origin.x = 0.0;
	}
	if(frame.size.height < scrollView.bounds.size.height)
	{
		frame.origin.y = (scrollView.bounds.size.height - frame.size.height) / 2.0;
	}
	else
	{
		frame.origin.y = 0.0;
	}
	zoomView.frame = frame;
}

@end
