//
//  DataInstance.h
//  LocalPlaces
//
//  Created by Rayan on 17/12/15.
//  Copyright © 2015 Rayan. All rights reserved
//

#import <Foundation/Foundation.h>

@interface DataInstance : NSObject

@property (strong, nonatomic) NSString *latitude;
@property (strong, nonatomic) NSString *longitude;

@property (strong, nonatomic) NSMutableDictionary *globalDictionaryCache;
//@property (strong, nonatomic) NSDictionary *globalCache;

+ (DataInstance *)getInstance;

@end
