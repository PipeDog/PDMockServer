//
//  NSDictionary+PDAdd.m
//  PDMockServer
//
//  Created by liang on 2018/3/16.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import "NSDictionary+PDAdd.h"

@implementation NSDictionary (PDAdd)

- (NSString *)toJSONString {
    NSString *JSONString;
    NSError *error;
    // Pass 0 if you don't care about the readability of the generated string
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
    if (!jsonData) {
        NSLog(@"NSDictionary parse to JSONString failed, error = (%@).", error);
    } else {
        JSONString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return JSONString;
}

- (NSData *)toData {
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
    if (error) NSLog(@"NSDictionary parse to NSData failed, error = (%@).", error);
    return data;
}

@end
