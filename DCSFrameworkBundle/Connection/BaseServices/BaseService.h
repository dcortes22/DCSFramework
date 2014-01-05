//
//  BaseService.h
//  DCSFramework
//
//  Created by David Cortés Sáenz on 31/12/13.
//  Copyright (c) 2013 DCS014. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServiceDelegate.h"
#import "AFHTTPRequestOperationManager.h"

@interface BaseService : NSObject{
    
}

@property (nonatomic, strong) id <ServiceDelegate> delegate;
@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;
- (id) initWithDelegate:(id<ServiceDelegate>) serviceDelegate;
- (id) initWithDelegate:(id<ServiceDelegate>) serviceDelegate AndBaseUrl:(NSURL *)url;
- (void) onConnectionError:(NSError *) error withCode:(NSString *)errorCode withMessage:(NSString *) errorMessage;
- (void) onServiceSucceeded:(id) object;
- (void) onServiceError:(NSString *)errorCode withMessage:(NSString *) errorMessage;

@end
