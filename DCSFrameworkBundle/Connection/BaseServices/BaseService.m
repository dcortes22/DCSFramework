//
//  BaseService.m
//  DCSFramework
//
//  Created by David Cortés Sáenz on 31/12/13.
//  Copyright (c) 2013 DCS014. All rights reserved.
//

#import "BaseService.h"

@implementation BaseService

@synthesize delegate = _delegate, manager = _manager;

//Simple constructor
- (id)initWithDelegate:(id)serviceDelegate {
    self = [super init];
    if (self != nil) {
        self.delegate = serviceDelegate;
        self.manager = [AFHTTPRequestOperationManager manager];
    }
    return self;
}
//Constructor using base URL
- (id) initWithDelegate:(id<ServiceDelegate>) serviceDelegate AndBaseUrl:(NSURL *)url{
    self = [super init];
    if (self != nil) {
        self.delegate = serviceDelegate;
        self.manager = [[AFHTTPRequestOperationManager init] initWithBaseURL:url];
    }
    return self;
}

// Makes the delegate callback onConnectionError
- (void)onConnectionError:(NSError *) error withCode:(NSString *)errorCode withMessage:(NSString *) errorMessage {
    if ([self.delegate respondsToSelector:@selector(service:onConnectionError:)]) {
        [[self delegate] service:self onConnectionError:error];
    }
}

// Makes the delegate callback onServiceSucceeded
- (void) onServiceSucceeded:(id) object {
    if ([self.delegate respondsToSelector:@selector(service:onServiceSuccess:)]) {
        [[self delegate] service:self onServiceSuccess:object];
    }
}

// Makes the delegate callback onServiceError
- (void) onServiceError:(NSString *)errorCode withMessage:(NSString *)errorMessage {
    if ([self.delegate respondsToSelector:@selector(service:onServiceError:)]) {
        NSError *error = nil;
        [[self delegate] service:self onServiceError:error];
    }
    // Get error code and take appropiate actions. Show an alert, try another request with different params?
    //int intErrorCode = [errorCode intValue];
}

@end
