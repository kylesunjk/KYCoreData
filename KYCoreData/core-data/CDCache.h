//
//  CDCache.h
//  PMI SAT
//
//  Created by Ethan Hunt on 6/4/14.
//  Copyright (c) 2014 Massive Infinity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CDCache : NSManagedObject

@property (nonatomic, retain) NSString *json;
@property (nonatomic, retain) NSNumber *timestamp;
@property (nonatomic, retain) NSString *uri;

@end
