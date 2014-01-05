//
//  Author.h
//  DCSFramework
//
//  Created by David Cortés Sáenz on 04/01/14.
//  Copyright (c) 2014 DCS014. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Author : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * uri;

@end
