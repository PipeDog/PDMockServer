//
//  PDMockResponse.m
//  PDMockServer
//
//  Created by liang on 2018/3/16.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import "PDMockResponse.h"
#import "NSDictionary+PDAdd.h"
#import "NSString+PDAdd.h"
#import "NSData+PDAdd.h"

@implementation PDMockResponse

+ (instancetype)make:(void (^)(PDMockResponse * _Nonnull))make {
    PDMockResponse *response = [[PDMockResponse alloc] init];
    if (make) make(response);
    return response;
}

#pragma mark - Setter Methods
- (void)setPath:(NSString *)path {
    _path = [path copy];
    
    NSURL *URL = [NSURL fileURLWithPath:path isDirectory:NO];
    _data = [NSData dataWithContentsOfURL:URL];
    _dict = [_data toDictionary];
    _JSONString = [_data toJSONString];
}

- (void)setDict:(NSDictionary *)dict {
    _dict = [dict copy];
    _JSONString = [_dict toJSONString];
    _data = [_dict toData];
}

- (void)setJSONString:(NSString *)JSONString {
    _JSONString = [JSONString copy];
    _dict = [_JSONString toDictionary];
    _data = [_dict toData];
}

- (void)setDelay:(NSTimeInterval)delay {
    NSAssert(delay >= 0, @"It can't be less than 0");
    _delay = delay;
}

@end
