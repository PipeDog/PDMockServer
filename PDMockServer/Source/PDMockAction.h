//
//  PDMockAction.h
//  PDMockServer
//
//  Created by liang on 2018/3/16.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PDMockResponse;

NS_ASSUME_NONNULL_BEGIN

typedef BOOL (^PDMockRequestCondition)(__kindof NSURLRequest *_Nullable request);
typedef PDMockResponse * _Nonnull (^PDMockResponseHandler)(__kindof NSURLRequest *_Nullable request);

@interface PDMockAction : NSObject

@property (nonatomic, copy, nonnull) PDMockRequestCondition condition;
@property (nonatomic, copy, nonnull) PDMockResponseHandler handler;

+ (instancetype)actionWithRequestCondition:(PDMockRequestCondition)condition responseHandler:(PDMockResponseHandler)handler;

- (instancetype)initWithRequestCondition:(PDMockRequestCondition)condition responseHandler:(PDMockResponseHandler)handler;

@end

NS_ASSUME_NONNULL_END
