//
//  NSData+PDAdd.m
//  PDMockServer
//
//  Created by liang on 2018/3/16.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import "NSData+PDAdd.h"

@implementation NSData (PDAdd)

- (NSDictionary *)toDictionary {
    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:self options:NSJSONReadingMutableContainers error:&error];
    if (error) NSLog(@"NSData parse to NSDictionary failed, error = (%@).", error);
    return dict;
}

- (NSString *)toJSONString {
    return [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
}

@end
