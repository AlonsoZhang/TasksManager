//
//  TaskGet.m
//  TasksManager
//
//  Created by Alonso on 2018/1/4.
//  Copyright © 2018年 Alonso. All rights reserved.
//

#import "TaskGet.h"
@interface TaskGet ()<NSURLSessionDelegate,NSURLSessionDataDelegate>
@property (nonatomic,strong ) NSMutableData *data;


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
            self.returnArr = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            result = true;
        }
        dispatch_semaphore_signal(semaphore);
    }];
    [task resume];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return result;
}

#pragma mark-  NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    if(!self.data){
        self.data = [NSMutableData data];
    }
    [self.data appendData:data];
}

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error {
    //NSString *responseStr = [[NSString alloc]initWithData:self.data encoding:NSUTF8StringEncoding];
    if (error) {
        NSLog(@"%@",error.localizedDescription);
    }
    if (self.data) {
        NSArray *aaa = [NSJSONSerialization JSONObjectWithData:self.data options:kNilOptions error:nil];
        NSLog(@"%@",aaa);
    }
}

@end
