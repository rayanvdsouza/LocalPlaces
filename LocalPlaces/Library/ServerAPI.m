//
//  ServerAPI.m
//  LocalPlaces
//
//  Created by Rayan on 17/12/15.
//  Copyright © 2015 Rayan. All rights reserved
//

#import "ServerAPI.h"

#import "Place.h"
#import "Photo.h"

@implementation ServerAPI

+ (void)initialize {
	
	if (self == [super class])
	{
		
	}
}

+ (void)getNearByPlacesInLocation:(NSString *)latitude longitude:(NSString *)longitude radius:(NSInteger)radius type:(NSString *)type pageToken:(NSString *)pageToken completion:(void (^)(NSArray *objects, NSString *nextPageToken, NSError *error))callback {
    
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%@,%@&radius=%ld&types=%@&key=%@",latitude,longitude,radius,type,GOOGLE_MAP_KEY];
    
    if (pageToken != nil)
    {
        urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%@,%@&radius=%ld&types=%@&key=%@&pagetoken=%@",latitude,longitude,radius,type,GOOGLE_MAP_KEY,pageToken];
    }
    
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *jsonData = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if([data length] > 0)
        {
            NSError *err = nil;
            NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];
            
            NSArray *results = (NSArray *)[responseObject objectForKey:@"results"];
            NSError *error = nil;
            NSString *nextPageToken = [responseObject objectForKey:@"next_page_token"];
            
            NSMutableArray *placesList = [[NSMutableArray alloc] init];
            for(int i = 0; i < [results count]; i++)
            {
                Place *object = [[Place alloc] initWithDictionary:results[i]];
				object.type = type;
                [placesList addObject:object];
            }
            
            NSLog(@"JSON responseObject: %@ ",responseObject);
			
			dispatch_async(dispatch_get_main_queue(), ^{
				
				callback(placesList, nextPageToken,  error);
			});
        }
        else
        {
			dispatch_async(dispatch_get_main_queue(), ^{
				
				callback(nil, nil, error);
			});
        }
    }];
    
    [jsonData resume];
}

+ (void)getPlaceDetails:(NSString *)placeId completion:(void (^)(Place *object, NSError *error))callback {
	
	NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?placeid=%@&key=%@",placeId,GOOGLE_MAP_KEY];
	
	NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
	[request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
	[request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPMethod:@"GET"];
	
	
	NSURLSession *session = [NSURLSession sharedSession];
	NSURLSessionDataTask *jsonData = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
		
		if([data length] > 0)
		{
			NSError *err = nil;
			NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];
			NSDictionary *result = [responseObject objectForKey:@"result"];

			Place *object = [[Place alloc] initWithDictionary:result];
			
			NSLog(@"JSON responseObject: %@ ",responseObject);
			
			dispatch_async(dispatch_get_main_queue(), ^{
				
				callback(object, error);
			});
		}
		else
		{
			dispatch_async(dispatch_get_main_queue(), ^{
				
				callback(nil, error);
			});
		}
	}];
	
	[jsonData resume];
}


@end
