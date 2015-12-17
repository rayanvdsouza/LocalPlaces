//
//  ServerAPI.h
//  LocalPlaces
//
//  Created by Rayan on 17/12/15.
//  Copyright © 2015 Rayan. All rights reserved
//

#import <Foundation/Foundation.h>

@class Place;

@interface ServerAPI : NSObject

+ (void)getNearByPlacesInLocation:(NSString *)latitude longitude:(NSString *)longitude radius:(NSInteger)radius type:(NSString *)type pageToken:(NSString *)pageToken completion:(void (^)(NSArray *objects, NSString *nextPageToken, NSError *error))callback;

+ (void)getPlaceDetails:(NSString *)placeId completion:(void (^)(Place *object, NSError *error))callback;

@end
