//
//  AppDelegate.h
//  DCSFramework
//
//  Created by David Cortés Sáenz on 30/12/13.
//  Copyright (c) 2013 DCS014. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
