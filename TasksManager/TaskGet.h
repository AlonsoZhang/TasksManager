//
//  TaskGet.h
//  TasksManager
//
//  Created by Alonso on 2018/1/4.
//  Copyright © 2018年 Alonso. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaskGet : NSObject{
}
@property (nonatomic,strong ) NSArray *returnArr;
- (id)init;
- (BOOL)queryPHPwithParameter:(NSString *)parameter withURL:(NSURL *)phpurl;
@end
