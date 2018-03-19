//
//  PDDataProcess.m
//  PDMockServer
//
//  Created by liang on 2018/3/19.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import "PDDataProcess.h"

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

@implementation NSString (PDAdd)

- (NSDictionary *)toDictionary {
    NSData *JSONData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableContainers error:&error];
    if (error) NSLog(@"NSString parse to NSDictionary failed, error = (%@).", error);
    return dict;
}

- (NSData *)toData {
    return [self dataUsingEncoding:NSUTF8StringEncoding];
}

@end

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
