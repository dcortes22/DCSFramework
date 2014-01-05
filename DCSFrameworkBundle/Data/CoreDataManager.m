//
//  CoreDataManager.m
//  DCSFramework
//
//  Created by David Cortés Sáenz on 31/12/13.
//  Copyright (c) 2013 DCS014. All rights reserved.
//

#import "CoreDataManager.h"
#import <objc/runtime.h>

@implementation CoreDataManager

#pragma mark - Constructor

+ (id)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

#pragma mark - Core Data Stack

- (void)setDataBaseName:(NSString *)dataBase{
    kDatabaseName = dataBase;
}

- (void)ensureThatTheManagedObjectContextHasBeenLoaded
{
    [self managedObjectContext];
}

- (NSManagedObjectContext *)currentThreadsManagedObjectContext
{
    return [self managedObjectContext];
}

- (void)contextDidSave:(NSNotification *)notification {
    SEL selector = @selector(mergeChangesFromContextDidSaveNotification:);
    [[[CoreDataManager sharedInstance] managedObjectContext] performSelectorOnMainThread:selector withObject:notification waitUntilDone:YES];
}

- (void)saveContext {
    NSError *error = nil;
    
    NSManagedObjectContext *moc = [self currentThreadsManagedObjectContext];
    if (moc != nil) {
        if ([moc hasChanges] && ![moc save:&error]) {
			NSLog(@"Failed to save Core Data context. Unresolved error %@, %@", error, [error userInfo]);
            NSLog(@"Failed to save to data store: %@", [error localizedDescription]);
            NSArray* detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
            if(detailedErrors != nil && [detailedErrors count] > 0) {
                for(NSError* detailedError in detailedErrors) {
                    NSLog(@"  DetailedError: %@", [detailedError userInfo]);
                }
            }
            else {
                NSLog(@"%@", [error userInfo]);
            }
			abort();
        }
    }
}

- (void)deleteEntity:(id)entity {
    NSManagedObjectContext *contextForThread = [[[NSThread currentThread] threadDictionary] objectForKey:@"ManagedObjectContextKey"];
    if (contextForThread != nil) {
        [contextForThread deleteObject:entity];
        [self saveContext];
    }
}

- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSManagedObjectContext *)managedObjectContext {
	
    NSManagedObjectContext *contextForThread = [[[NSThread currentThread] threadDictionary] objectForKey:@"ManagedObjectContextKey"];
    if (contextForThread != nil) {
        return contextForThread;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        contextForThread = [[NSManagedObjectContext alloc] init];
        [contextForThread setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        [contextForThread setPersistentStoreCoordinator: coordinator];
        [contextForThread setUndoManager:nil];
        [[[NSThread currentThread] threadDictionary] setObject:contextForThread forKey:@"ManagedObjectContextKey"];
        if ([NSThread currentThread] == [NSThread mainThread]) {
            managedObjectContext = contextForThread;
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(contextDidSave:)
                                                         name:NSManagedObjectContextDidSaveNotification
                                                       object:nil];
        }
    }
    
    return [[[NSThread currentThread] threadDictionary] objectForKey:@"ManagedObjectContextKey"];
}

- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    return managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    
	NSString *storePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", kDatabaseName]];
	
	// set up the backing store
	NSFileManager *fileManager = [NSFileManager defaultManager];
	// If the expected store doesn't exist, copy the default store.
	if (![fileManager fileExistsAtPath:storePath]) {
		NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:kDatabaseName ofType:@"sqlite"];
		if (defaultStorePath) {
			[fileManager copyItemAtPath:defaultStorePath toPath:storePath error:NULL];
		}
	}
	
	NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
	
	NSError *error;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate.
        // You should not use this function in a shipping application, although it may be useful
        // during development. If it is not possible to recover from the error, display an alert
        // panel that instructs the user to quit the application by pressing the Home button.
        //
        
        // Typical reasons for an error here include:
        // The persistent store is not accessible
        // The schema for the persistent store is incompatible with current managed object model
        // Check te error message to determine what the actual problem was.
        //
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
    }
    
    return persistentStoreCoordinator;
}

- (NSArray *) getDistinctValuesForEntityProperty:(NSString*) entityName forProperty:(NSString*) property withSorting:(NSString *) sortColumn withPredicate:(NSPredicate*) predicate{
    NSFetchRequest * req = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
    NSDictionary *entityProperties = [entity propertiesByName];
    [req setEntity:entity];
    [req setReturnsDistinctResults:YES];
    [req setPropertiesToFetch:[NSArray arrayWithObject:[entityProperties objectForKey:property]]];
    [req setSortDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:sortColumn ascending:YES]]];
    [req setResultType:NSDictionaryResultType];
    
    if (predicate != nil) {
        [req setPredicate:predicate];
    }
    NSArray *result = [managedObjectContext executeFetchRequest:req error:nil];
    return result;
}

- (id) getEntity:(NSString*) entityName withField:(NSString *) fieldName withValue:(NSString *) fieldValue {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:fieldName, fieldValue];
    NSArray *values = [self getEntities:entityName withPredicate:predicate withSortColumn:nil];
    
    if ([values count] > 0) return [values objectAtIndex:0]; else return nil;
}

- (id) getEntity:(NSString *)entityName withPredicate:(NSPredicate *) predicate{
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
    [req setEntity:entity];
    [req setReturnsDistinctResults:YES];
    [req setResultType:NSManagedObjectResultType];
    
    NSArray *result = [managedObjectContext executeFetchRequest:req error:nil];
    if ([result count] > 0) return [result objectAtIndex:0]; else return nil;
}

- (int) entityCount:(NSString*) entityName withPredicate:(NSPredicate*) predicate {
    NSFetchRequest * req = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
    [req setEntity:entity];
    [req setReturnsDistinctResults:YES];
    [req setResultType:NSCountResultType];
    
    if (predicate != nil) {
        [req setPredicate:predicate];
    }
    
    NSArray *result = [managedObjectContext executeFetchRequest:req error:nil];
    return [[result objectAtIndex:0] intValue];
}

- (int) maxFieldValue:(NSString*) entityName withField:(NSString *)field withPredicate:(NSPredicate*) predicate withFunction:(NSString *) function {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
    [request setEntity:entity];
    // Specify that the request should return dictionaries.
    [request setResultType:NSDictionaryResultType];
    // Create an expression for the key path.
    NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:field];
    // Create an expression to represent the minimum value at the key path 'creationDate'
    NSExpression *minExpression = [NSExpression expressionForFunction:[NSString stringWithFormat:@"%@:", function] arguments:[NSArray  arrayWithObject:keyPathExpression]];
    // Create an expression description using the minExpression and returning a date.
    NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
    // The name is the key that will be used in the dictionary for the return value.
    
    NSString *fieldName = [NSString stringWithFormat:@"%@%@",field, function];
    [expressionDescription setName:fieldName];
    [expressionDescription setExpression:minExpression];
    [expressionDescription setExpressionResultType:NSInteger32AttributeType];
    
    // Set the request's properties to fetch just the property represented by the expressions.
    [request setPropertiesToFetch:[NSArray arrayWithObject:expressionDescription]];
    // Execute the fetch.
    NSError *error = nil;
    NSArray *objects = [managedObjectContext executeFetchRequest:request error:&error];
    
    if (objects == nil) {
        // Handle the error
        return 0;
    }
    else {
        if ([objects count] > 0) {
            NSLog(@"Function result : %@", [[objects objectAtIndex:0] valueForKey:fieldName]);
        }
    }
    
    return [[[objects objectAtIndex:0] valueForKey:fieldName] intValue];
}

- (NSArray *) getEntities:(NSString*) entityName withPredicate:(NSPredicate*) predicate withSortColumn:(NSString *) sortColumn {
    return [self getEntities:entityName withPredicate:predicate withSortColumn:sortColumn ascending:YES];
}

- (NSArray *) getEntities:(NSString*) entityName withPredicate:(NSPredicate*) predicate withSortColumn:(NSString *) sortColumn ascending:(BOOL) ascending {
    NSFetchRequest * req = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
    [req setEntity:entity];
    [req setReturnsDistinctResults:YES];
    [req setResultType:NSManagedObjectResultType];
    
    if (sortColumn != nil) {
        [req setSortDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:sortColumn ascending:ascending]]];
    }
    
    if (predicate != nil) {
        [req setPredicate:predicate];
    }
    NSArray *result = [managedObjectContext executeFetchRequest:req error:nil];
    return result;
}

- (void) deleteAllInstancesOfEntity:(NSString*) entityName withPredicate:(NSPredicate*) predicate {
    NSFetchRequest * allEntities = [[NSFetchRequest alloc] init];
    [allEntities setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext]];
    [allEntities setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    if (predicate != nil) {
        [allEntities setPredicate:predicate];
    }
    
    NSError * error = nil;
    NSArray * entities = [managedObjectContext executeFetchRequest:allEntities error:&error];
    //error handling goes here
    for (NSManagedObject * entity in entities) {
        [managedObjectContext deleteObject:entity];
    }
    NSError *saveError = nil;
    [managedObjectContext save:&saveError];
}

- (id) entityOfType:(NSString *) entity {
    return [NSEntityDescription insertNewObjectForEntityForName:entity inManagedObjectContext:[CoreDataManager.sharedInstance managedObjectContext]];
}

- (id)addOrUpdateObjectFromJSONDictionary:(id)jsonDictionary entity:(NSString *)name idObjectName:(NSString *)keyName{
    if (jsonDictionary != nil && [jsonDictionary isKindOfClass:[NSDictionary class]]) {
        NSString *predicateQuery = [NSString stringWithFormat:@"%@ = %@", keyName, @"%@"];
        NSString *keyValue = [jsonDictionary objectForKey:keyName];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateQuery, keyValue];
        
        id object = [self getEntity:name withPredicate:predicate];
        
        if (object == nil){
            object = [NSEntityDescription insertNewObjectForEntityForName:name inManagedObjectContext:managedObjectContext];
        }
        
        //Parse the object....
        object = [self parseDictionary:jsonDictionary toObject:object];
        
        return object;
    }
    
    return nil;
}

#pragma mark - Parse Objects
- (NSDictionary *)getObjectSpecification:(id)object{
    NSMutableDictionary *propertiesDic = [NSMutableDictionary dictionary];
    unsigned int count;
    objc_property_t* properties = class_copyPropertyList([object class], &count);
    
    for (int i = 0; i < count; i++)
    {
        objc_property_t property = properties[i];
        
        NSString* propName = [NSString stringWithUTF8String:property_getName(property)];
        
        NSString* attrs = [NSString stringWithUTF8String: property_getAttributes(property)];
        NSArray* attrParts = [attrs componentsSeparatedByString:@","];
        if (attrParts != nil && attrParts.count > 0)
        {
            NSString* className = [[attrParts objectAtIndex:0] substringFromIndex:1];
            className = [className stringByReplacingOccurrencesOfString:@"@" withString:@""];
            className = [className stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            [propertiesDic setObject:className forKey:propName];
        }
    }
    
    free(properties);
    return [NSDictionary dictionaryWithDictionary:propertiesDic];
}

- (id)parseDictionary:(NSDictionary *)dictionary toObject:(id)object{
    
    //Get the object fields and specification
    NSDictionary *objectDef = [self getObjectSpecification:object];
    
    //Check the data dictionary and object specification are not null
    if (dictionary && objectDef) {
        NSArray *defKeys = [objectDef allKeys];
        if (defKeys) {
            for (NSString * key in defKeys){
                id value = [self getValueFromDictionary:dictionary withKey:key andObjectSpecification:objectDef];
                
                if (value == nil) {
                    char *ivarPropertyName = property_copyAttributeValue((__bridge objc_property_t)(key), "V");
                    if(ivarPropertyName != NULL){
                        NSString *ivarName = @(ivarPropertyName);
                        value = [self getValueFromDictionary:dictionary withKey:ivarName andObjectSpecification:objectDef];
                    }
                    free (ivarPropertyName);
                }
                [object setValue:value forKey:key];
            }
        }
    }
    
    return object;
    
}

- (id)getValueFromDictionary:(NSDictionary *)dictionary withKey:(NSString *)key andObjectSpecification:(NSDictionary *)objectSpecification{
    NSString *propertyTypeString = [objectSpecification objectForKey:key];
    Class propertyClass = NSClassFromString(propertyTypeString);
    id value = [dictionary objectForKey:key];
    
    if ([value isKindOfClass:[NSNull class]] || !value || [value isKindOfClass:[NSDictionary class]]) {
        value = nil;
    }else if ([propertyClass isSubclassOfClass:[NSString class]] && [value isKindOfClass:[NSNumber class]]){
        value = [value stringValue];
    }else if ([propertyClass isSubclassOfClass:[NSNumber class]] && [value isKindOfClass:[NSString class]]){
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc]init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        value = [numberFormatter numberFromString:value];
    }
    
    return value;
}

@end
