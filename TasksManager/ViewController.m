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
    dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss.sss"];
    runtimer = true;
    [self timerAction];
    NSTimer *timer = [NSTimer timerWithTimeInterval:5 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

- (void)timerAction{
    if (runtimer){
        runtimer = false;
        [self addLog:@"Start"];
        NSArray * taskArr = [[NSArray alloc]init];
        NSURL *phpURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/List_Task.php",[ConfigPlist objectForKey:@"phpURL"]]];
        if([self queryPHPwithParameter:nil withURL:phpURL]){
            NSDictionary *phpReturnDic = _phpReturnArr[0];
            if ([[phpReturnDic objectForKey:@"Result"] isEqualToString:@"Pass"]) {
                taskArr = [phpReturnDic objectForKey:@"Data"];
                NSLog(@"%@",taskArr);
                dispatch_queue_t queue= dispatch_queue_create("test.queue", DISPATCH_QUEUE_CONCURRENT);//异步并行
                for (NSDictionary *eachtaskDic in taskArr) {
                    //NSLog(@"%@",eachtaskDic);
                    dispatch_async(queue, ^{
                        TaskGet *taskGet = [[TaskGet alloc]init];
                        [self addLog:[NSString stringWithFormat:@"%@ start",[eachtaskDic objectForKey:@"Task_Type"]]];
                        NSString * parameter = [NSString stringWithFormat:@"Task_ID=%@&Task_Type=%@",[eachtaskDic objectForKey:@"Task_ID"],[eachtaskDic objectForKey:@"Task_Type"]];
                        NSURL *phpGetURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/GET_Task.php",[ConfigPlist objectForKey:@"phpURL"]]];
                        if([taskGet queryPHPwithParameter:parameter withURL:phpGetURL]){
                            NSArray *aaa = [NSJSONSerialization JSONObjectWithData:taskGet.returnData options:kNilOptions error:nil];
                            NSLog(@"%@",aaa[0]);
                            [self addLog:[NSString stringWithFormat:@"%@ end",[eachtaskDic objectForKey:@"Task_Type"]]];
                        }
                    });
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

- (void)addLog:(NSString *)log{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *dateStr = [dateFormat stringFromDate:[NSDate date]];
        if (self.textView.string.length == 0) {
            self.textView.string = [NSString stringWithFormat:@"%@ : %@",dateStr,log];
        }else{
            self.textView.string = [NSString stringWithFormat:@"%@\n%@ : %@",self.textView.string,dateStr,log];
        }
    });
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
