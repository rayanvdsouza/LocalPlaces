//
//  Photo.m
//  LocalPlaces
//
//  Created by Rayan on 17/12/15.
//  Copyright © 2015 Rayan. All rights reserved
//

#import "Photo.h"

@implementation Photo

@synthesize height;
@synthesize width;
@synthesize photoReference;



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
		height = [(NSNumber *)[dictionary objectForKey:@"height"] integerValue];
		width = [(NSNumber *)[dictionary objectForKey:@"width"] integerValue];

		photoReference = [dictionary objectForKey:@"photo_reference"];
		
	}
	return self;
}



@end
