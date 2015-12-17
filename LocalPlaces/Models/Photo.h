//
//  Photo.h
//  LocalPlaces
//
//  Created by Rayan on 17/12/15.
//  Copyright © 2015 Rayan. All rights reserved
//

#import <Foundation/Foundation.h>

@interface Photo : NSObject

@property (nonatomic) NSInteger height;
@property (nonatomic) NSInteger width;
@property (strong, nonatomic) NSString *photoReference;


- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
