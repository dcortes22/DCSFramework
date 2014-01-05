//
//  YouTubeService.m
//  DCSFramework
//
//  Created by David Cortés Sáenz on 04/01/14.
//  Copyright (c) 2014 DCS014. All rights reserved.
//

#import "YouTubeService.h"

@implementation YouTubeService

-(NSDictionary *)getVideos{
    [self.manager GET:@"http://gdata.youtube.com/feeds/api/users/nyscopbainc/uploads" parameters:[NSDictionary dictionaryWithObjectsAndKeys:@"2", @"v", @"json", @"alt", nil] success:^(AFHTTPRequestOperation *operation, id responseObject){
        NSDictionary *result = (NSDictionary *)responseObject;
        NSArray *entries = [[result objectForKey:@"feed"] objectForKey:@"entry"];
        [self onServiceSucceeded:entries];
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        [self onConnectionError:error withCode:@"" withMessage:@""];
    }];
    
    return nil;
}

@end
