//
//  ViewController.h
//  TasksManager
//
//  Created by Alonso on 2018/1/3.
//  Copyright © 2018年 Alonso. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MIC.h"

@interface ViewController : NSViewController{
    NSMutableDictionary *ConfigPlist;
    NSDateFormatter *dateFormat;
    BOOL runtimer;
}
@property (strong, nonatomic) NSArray *phpReturnArr;
@property (unsafe_unretained) IBOutlet NSTextView *textView;

@end

