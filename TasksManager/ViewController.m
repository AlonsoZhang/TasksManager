//
//  ViewController.m
//  TasksManager
//
//  Created by Alonso on 2018/1/3.
//  Copyright © 2018年 Alonso. All rights reserved.
//

#import "ViewController.h"
#import "TaskGet.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    ConfigPlist = [[NSMutableDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Config" ofType:@"plist"]];
    runtimer = true;
    [self timerAction];
    NSTimer *timer = [NSTimer timerWithTimeInterval:5 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

- (void)timerAction{
    if (runtimer){
        runtimer = false;
        NSArray * taskArr = [[NSArray alloc]init];
        NSURL *phpURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/List_Task.php",[ConfigPlist objectForKey:@"phpURL"]]];
        if([self queryPHPwithParameter:nil withURL:phpURL]){
            NSDictionary *phpReturnDic = _phpReturnArr[0];
            if ([[phpReturnDic objectForKey:@"Result"] isEqualToString:@"Pass"]) {
                taskArr = [phpReturnDic objectForKey:@"Data"];
                for (NSDictionary *eachtaskDic in taskArr) {
                    //NSLog(@"%@",eachtaskDic);
                    TaskGet *taskGet = [[TaskGet alloc]init];
                    //http://10.42.222.70/DataMining/GET_Task.php?Task_ID=IT1111&Task_Type=IT-4
                    NSString * parameter = [NSString stringWithFormat:@"Task_ID=%@&Task_Type=%@",[eachtaskDic objectForKey:@"Task_ID"],[eachtaskDic objectForKey:@"Task_Type"]];
                    NSURL *phpGetURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/GET_Task.php",[ConfigPlist objectForKey:@"phpURL"]]];
                    [taskGet queryPHPwithParameter:parameter withURL:phpGetURL];
                }
            }
        }
    }
}

- (BOOL)queryPHPwithParameter:(NSString *)parameter withURL:(NSURL *)phpurl
{
    __block BOOL result = false;
    _phpReturnArr = [[NSArray alloc]init];
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
            _phpReturnArr = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            result = true;
        }
        dispatch_semaphore_signal(semaphore);
    }];
    [task resume];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return result;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
