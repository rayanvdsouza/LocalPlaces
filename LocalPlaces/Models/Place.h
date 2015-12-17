//
//  Place.h
//  LocalPlaces
//
//  Created by Rayan on 17/12/15.
//  Copyright © 2015 Rayan. All rights reserved
//

#import <Foundation/Foundation.h>

@interface Place : NSObject

@property (nonatomic, copy) NSString *_id;
@property (strong, nonatomic) NSString *icon;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *type;
@property (nonatomic) BOOL *isOpenNow;
@property (strong, nonatomic) NSArray *photos;
@property (strong, nonatomic) NSString *placeId;
@property (strong, nonatomic) NSString *reference;
@property (strong, nonatomic) NSString *vicinity;
@property (strong, nonatomic) NSString *address;

@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
