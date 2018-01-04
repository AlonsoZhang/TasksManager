//
//  ViewController.h
//  TasksManager
//
//  Created by Alonso on 2018/1/3.
//  Copyright © 2018年 Alonso. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController{
    NSMutableDictionary *ConfigPlist;
    BOOL runtimer;
}
@property (strong, nonatomic) NSArray *phpReturnArr;

@end

