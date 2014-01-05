//
//  ServiceDelegate.h
//  DCSFramework
//
//  Created by David Cortés Sáenz on 31/12/13.
//  Copyright (c) 2013 DCS014. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BaseService;
@protocol ServiceDelegate <NSObject>

@required

- (void)service:(BaseService *)service onServiceSuccess:(id)object;
- (void)service:(BaseService *)service onServiceError:(NSError *)error;
- (void)service:(BaseService *)service onConnectionError:(NSError *)error;

@end
