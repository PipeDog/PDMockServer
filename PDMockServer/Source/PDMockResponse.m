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

@synthesize data = _data;
@synthesize path = _path;
@synthesize dict = _dict;
@synthesize JSONString = _JSONString;
@synthesize error = _error;
@synthesize delay = _delay;

+ (instancetype)responseWithBuilder:(void (^)(id<PDMockResponse> _Nonnull))block {
    id<PDMockResponse> response = [[self alloc] init];
    !block ?: block(response);
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
    _data = PDValueToData(_dict);
}

- (void)setJSONString:(NSString *)JSONString {
    _JSONString = [JSONString copy];
    _data = PDValueToData(_JSONString);
}

- (void)setDelay:(NSTimeInterval)delay {
    NSAssert(delay >= 0, @"It can't be less than 0");
    _delay = delay;
}

#pragma mark - Getter Methods
- (NSDictionary *)dict {
    if (!_dict) {
        if (self.data) {
            _dict = PDValueToJSONObject(self.data);
        } else if (self.JSONString) {
            _dict = PDValueToJSONObject(self.data);
        }
    }
    return _dict;
}

- (NSString *)JSONString {
    if (!_JSONString) {
        if (self.data) {
            _JSONString = PDValueToJSONText(self.data);
        } else if (self.dict) {
            _JSONString = PDValueToJSONText(self.dict);
        }
    }
    return _JSONString;
}

@end
