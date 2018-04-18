//
//  PDMockAction.m
//  PDMockServer
//
//  Created by liang on 2018/3/16.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import "PDMockAction.h"

@implementation PDMockAction

+ (instancetype)actionWithResponseHandler:(PDMockResponseHandler)handler {
    return [self actionWithRequestCondition:^BOOL(__kindof NSURLRequest * _Nullable request) {
        return YES;
    } responseHandler:handler];
}

+ (instancetype)actionWithRequestCondition:(PDMockRequestCondition)condition
                           responseHandler:(PDMockResponseHandler)handler {
    return [[PDMockAction alloc] initWithRequestCondition:condition responseHandler:handler];
}

- (instancetype)initWithRequestCondition:(PDMockRequestCondition)condition
                         responseHandler:(PDMockResponseHandler)handler {
    self = [super init];
    if (self) {
        _condition = condition;
        _handler = handler;
    }
    return self;
}

@end
