//
// Created by Ethan Hunt on 4/4/14.
// Copyright (c) 2014 Massive Infinity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CDCache.h"

@interface MICacheData : NSObject {
}

- (CDCache *)dbLoad:(NSString *)uri;

- (void)dbSave:(NSString *)uri withContent:(NSString *)content withExpiry:(NSDate *)expiry;

- (void)dbSave:(NSString *)uri withContent:(NSString *)content;

- (void)dbDelete:(NSString *)uri;

+ (MICacheData *)singleton;
@end