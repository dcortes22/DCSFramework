//
//  MainViewController.h
//  DCSFramework
//
//  Created by David Cortés Sáenz on 30/12/13.
//  Copyright (c) 2013 DCS014. All rights reserved.
//

#import "FlipsideViewController.h"
#import "ServiceDelegate.h"
#import "YouTubeService.h"

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate, UIPopoverControllerDelegate, ServiceDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;

@end
