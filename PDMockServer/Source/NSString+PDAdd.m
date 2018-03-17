//
//  NSString+PDAdd.m
//  PDMockServer
//
//  Created by liang on 2018/3/16.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import "NSString+PDAdd.h"

@implementation NSString (PDAdd)

- (NSDictionary *)toDictionary {
    NSData *JSONData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableContainers error:&error];
    if (error) NSLog(@"NSString parse to NSDictionary failed, error = (%@).", error);
    return dict;
}

@end
