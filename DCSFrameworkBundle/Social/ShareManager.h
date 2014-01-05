//
//  ShareManager.h
//  DCSFramework
//
//  Created by David Cortés Sáenz on 04/01/14.
//  Copyright (c) 2014 DCS014. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIDelegate.h"
#import <UIKit/UIActivityViewController.h>

@interface ShareManager : NSObject<UIDelegate>{
    UIActivityViewController *activityController;
}

@property(nonatomic, assign) id<UIDelegate> delegate;

- (id)initWithDelegate:(id<UIDelegate>)delegate;
- (void)shareText:(NSString *)text;
- (void)shareText:(NSString *)text withItems:(NSArray *)items;

@end
