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

- (void)queryPHPwithParameter:(NSString *)parameter withURL:(NSURL *)phpurl
{
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    //[NSOperationQueue mainQueue]
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:phpurl];
    request.HTTPMethod = @"POST";
    [request setTimeoutInterval:5.0];
    request.HTTPBody = [parameter dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionTask *task = [session dataTaskWithRequest:request];
    [task resume];
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
