//
//  FlipsideViewController.h
//  DCSFramework
//
//  Created by David Cortés Sáenz on 30/12/13.
//  Copyright (c) 2013 DCS014. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIDelegate.h"
#import "ShareManager.h"

@class FlipsideViewController;

@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
@end

@interface FlipsideViewController : UIViewController<UIDelegate>

@property (weak, nonatomic) id <FlipsideViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;

- (IBAction)share:(id)sender;

@end
