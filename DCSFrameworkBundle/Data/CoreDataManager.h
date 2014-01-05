//
//  CoreDataManager.h
//  DCSFramework
//
//  Created by David Cortés Sáenz on 31/12/13.
//  Copyright (c) 2013 DCS014. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataManager : NSObject{
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSString *kDatabaseName;
}

@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (id)sharedInstance;
- (void)setDataBaseName:(NSString *)dataBase;
- (void)saveContext;
- (void)ensureThatTheManagedObjectContextHasBeenLoaded;
- (NSManagedObjectContext*)currentThreadsManagedObjectContext;


- (id)addOrUpdateObjectFromJSONDictionary:(id)jsonDictionary entity:(NSString *)name idObjectName:(NSString *)keyName;
- (id) getEntity:(NSString *)entityName withPredicate:(NSPredicate *) predicate;
- (NSDictionary *)getObjectSpecification:(id)object;
- (id)parseDictionary:(NSDictionary *)dictionary toObject:(id)object;
- (id)getValueFromDictionary:(NSDictionary *)dictionary withKey:(NSString *)key andObjectSpecification:(NSDictionary *)objectSpecification;


- (id) getEntity:(NSString*) entityName withField:(NSString *) fieldName withValue:(NSString *) fieldValue;
- (void)deleteEntity:(id)entity ;
- (NSArray *) getDistinctValuesForEntityProperty:(NSString*) entityName forProperty:(NSString*) property withSorting:(NSString *) sortColumn withPredicate:(NSPredicate*) predicate;
- (NSArray *) getEntities:(NSString*) entityName withPredicate:(NSPredicate*) predicate withSortColumn:(NSString *) sortColumn;
- (NSArray *) getEntities:(NSString*) entityName withPredicate:(NSPredicate*) predicate withSortColumn:(NSString *) sortColumn ascending:(BOOL) ascending;
- (void) deleteAllInstancesOfEntity:(NSString*) entityName withPredicate:(NSPredicate*) predicate;
- (id)  entityOfType:(NSString *) entity;
- (int) entityCount:(NSString*) entityName withPredicate:(NSPredicate*) predicate;
- (int) maxFieldValue:(NSString*) entityName withField:(NSString *)field withPredicate:(NSPredicate*) predicate withFunction:(NSString *) function;

@end
