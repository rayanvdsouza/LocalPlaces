//
//  Place.m
//  LocalPlaces
//
//  Created by Rayan on 17/12/15.
//  Copyright © 2015 Rayan. All rights reserved
//

#import "Place.h"

#import "Photo.h"

@implementation Place

@synthesize _id;
@synthesize icon;
@synthesize name;
@synthesize isOpenNow;
@synthesize photos;
@synthesize placeId;
@synthesize reference;
@synthesize vicinity;
@synthesize address;

@synthesize latitude;
@synthesize longitude;


- (instancetype)init {
	
	self = [super init];
	if (self)
	{
		
	}
	return self;
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
	
	if (![dictionary isKindOfClass:[NSDictionary class]])
	{
		return nil;
	}
	self = [super init];
	if (self)
	{
		_id = [dictionary objectForKey:@"id"];

        NSDictionary *location = [[dictionary objectForKey:@"geometry"] objectForKey:@"location"];

		icon = [dictionary objectForKey:@"icon"];
		name = [dictionary objectForKey:@"name"];
		//isOpenNow = [dictionary objectForKey:@"id"];
		photos = [self getPhotosForPlace:[dictionary objectForKey:@"photos"]];
		placeId = [dictionary objectForKey:@"place_id"];
		reference = [dictionary objectForKey:@"reference"];
		vicinity = [dictionary objectForKey:@"vicinity"];
		address = [dictionary objectForKey:@"formatted_address"];
		
        latitude = [(NSNumber *)[location objectForKey:@"lat"] doubleValue];
        longitude = [(NSNumber *)[location objectForKey:@"lng"] doubleValue];
	}
	return self;
}

- (NSArray *)getPhotosForPlace:(NSArray *)photosJson {

	NSMutableArray *photoArray = [[NSMutableArray alloc] init];
	
    for(int i = 0; i < photosJson.count; i++)
    {
        Photo *object = [[Photo alloc] initWithDictionary:photosJson[i]];
        
        [photoArray addObject:object];
    }
    return photoArray;
}


@end
