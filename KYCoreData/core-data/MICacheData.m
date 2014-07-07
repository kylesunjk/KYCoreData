//
// Created by Ethan Hunt on 4/4/14.
// Copyright (c) 2014 Massive Infinity. All rights reserved.
//

#import "MICacheData.h"


@implementation MICacheData {
    NSManagedObjectContext       *_managedObjectContext;
    NSManagedObjectModel         *_managedObjectModel;
    NSPersistentStoreCoordinator *_persistentStoreCoordinator;
}

#pragma mark db operation

- (CDCache *)dbLoad:(NSString *)uri {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    //Setting Entity to be Queried
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CDCache" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"uri = %@", uri]];

    // Query on managedObjectContext With Generated fetchRequest
    NSError *error;
    NSArray *fetchedRecords     = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];

    if ([fetchedRecords count] > 0) {
        return fetchedRecords[0];
    }
    else {
        return nil;
    }
}

- (void)dbSave:(NSString *)uri withContent:(NSString *)content withExpiry:(NSDate *)date {
    CDCache *cache = [self dbLoad:uri];
    if (cache == nil) {
        cache = [NSEntityDescription insertNewObjectForEntityForName:@"CDCache" inManagedObjectContext:[self managedObjectContext]];
    }

    double time = (double) [date timeIntervalSince1970];

    [cache setUri:uri];
    [cache setJson:content];
    [cache setTimestamp:[NSNumber numberWithDouble:time]];

    NSError *error;
    if (![[self managedObjectContext] save:&error]) {

    }
}

- (void)dbSave:(NSString *)uri withContent:(NSString *)content {
    CDCache *cache = [self dbLoad:uri];
    if (cache == nil) {
        cache = [NSEntityDescription insertNewObjectForEntityForName:@"CDCache" inManagedObjectContext:[self managedObjectContext]];
    }

    [cache setUri:uri];
    [cache setJson:content];
    [cache setTimestamp:[NSNumber numberWithDouble:(double)[[NSDate date] timeIntervalSince1970]]];

    NSError *error;
    if (![[self managedObjectContext] save:&error]) {

    }
}

- (void)dbDelete:(NSString *)uri {
    CDCache *cache = [self dbLoad:uri];
    if (cache != nil) {
        [[self managedObjectContext] deleteObject:cache];
    }
}

#pragma mark - CoreData stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }

    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }

    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }

    NSURL *storeURL = [[MICacheData applicationDocumentsDirectory] URLByAppendingPathComponent:@"cache.sqlite"];

    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    return _persistentStoreCoordinator;
}

#pragma mark - CoreData singleon

+ (MICacheData *)singleton {
    static MICacheData     *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });

    return sharedMyManager;
}


+ (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
@end