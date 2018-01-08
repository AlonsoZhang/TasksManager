//
//  TaskGet.m
//  TasksManager
//
//  Created by Alonso on 2018/1/4.
//  Copyright © 2018年 Alonso. All rights reserved.
//

#import "TaskGet.h"
@interface TaskGet ()

@end

@implementation TaskGet

- (id)init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

- (BOOL)queryPHPwithParameter:(NSString *)parameter withURL:(NSURL *)phpurl
{
    __block BOOL result = false;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:phpurl];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    request.HTTPMethod = @"POST";
    [request setTimeoutInterval:5.0];
    request.HTTPBody = [parameter dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"%@",error.localizedDescription);
        }
        if (data) {
            self.returnData = data;
            result = true;
        }
        dispatch_semaphore_signal(semaphore);
    }];
    [task resume];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return result;
}

@end
