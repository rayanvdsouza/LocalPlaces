//
//  DataInstance.m
//  LocalPlaces
//
//  Created by Rayan on 17/12/15.
//  Copyright © 2015 Rayan. All rights reserved
//

#import "DataInstance.h"

@implementation DataInstance


static DataInstance *instance = nil;

+ (DataInstance *)getInstance {
	
    @synchronized(self)
    {
        if(instance == nil)
        {
            instance = [[DataInstance alloc] init];
			
			instance.latitude = @"";
			instance.longitude = @"";
            
            instance.globalDictionaryCache = [[NSMutableDictionary alloc] init];
            
            //instance.globalCache = [[NSCache alloc] init];
	    }
    }
    return instance;
}

@end
