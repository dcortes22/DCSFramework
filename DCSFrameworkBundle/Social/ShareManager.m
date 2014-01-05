//
//  ShareManager.m
//  DCSFramework
//
//  Created by David Cortés Sáenz on 04/01/14.
//  Copyright (c) 2014 DCS014. All rights reserved.
//

#import "ShareManager.h"

@implementation ShareManager

@synthesize delegate = _delegate;

-(id)initWithDelegate:(id<UIDelegate>)delegate{
    self = [super init];
    if (self != nil) {
        self.delegate = delegate;
    }
    return self;
}

-(void)shareText:(NSString *)text{
    NSMutableArray *activityItems = [NSMutableArray array];
    [activityItems addObject:text];
    activityController = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
    if ([self.delegate respondsToSelector:@selector(presentViewController:animated:completion:)]) {
        [(UIViewController *)self.delegate presentViewController:activityController animated:YES completion:^{
            [self executeAfterDismiss];
        }];
    }
}

-(void)shareText:(NSString *)text withItems:(NSArray *)items{
    NSMutableArray *activityItems = [NSMutableArray arrayWithObject:text];
    [activityItems addObjectsFromArray:items];
    activityController = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
    if ([self.delegate respondsToSelector:@selector(presentViewController:animated:completion:)]) {
        [(UIViewController *)self.delegate presentViewController:activityController animated:YES completion:^{
            [self executeAfterDismiss];
        }];
    }
}

#pragma mark - UIDelegate
-(void)executeAfterDismiss{
    if ([self.delegate respondsToSelector:@selector(executeAfterDismiss)]) {
        [self.delegate executeAfterDismiss];
    }
}

@end
