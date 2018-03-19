//
//  PDMockResponse.m
//  PDMockServer
//
//  Created by liang on 2018/3/16.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import "PDMockResponse.h"
#import "PDDataProcess.h"

@implementation PDMockResponse

@synthesize dict = _dict;
@synthesize JSONString = _JSONString;

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
}

- (void)setDict:(NSDictionary *)dict {
    _dict = [dict copy];
    _data = [_dict toData];
}

- (void)setJSONString:(NSString *)JSONString {
    _JSONString = [JSONString copy];
    _data = [_JSONString toData];
}

- (void)setDelay:(NSTimeInterval)delay {
    NSAssert(delay >= 0, @"It can't be less than 0");
    _delay = delay;
}

#pragma mark - Getter Methods
- (NSDictionary *)dict {
    if (!_dict) {
        if (self.data) {
            _dict = [self.data toDictionary];
        } else if (self.JSONString) {
            _dict = [self.JSONString toDictionary];
        }
    }
    return _dict;
}

- (NSString *)JSONString {
    if (!_JSONString) {
        if (self.data) {
            _JSONString = [self.data toJSONString];
        } else if (self.dict) {
            _JSONString = [self.dict toJSONString];
        }
    }
    return _JSONString;
}

@end
