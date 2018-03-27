//
//  PDMockServer.h
//  PDMockServer
//
//  Created by liang on 2018/3/16.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PDMockResponse.h"
#import "PDMockAction.h"

NS_ASSUME_NONNULL_BEGIN

@interface PDMockServer : NSObject

@property (class, strong, readonly) PDMockServer *defaultServer;

- (void)switchEnabled:(BOOL)enabled; // NSURLConnection request call method.
- (void)switchEnabled:(BOOL)enabled forSessionConfiguration:(NSURLSessionConfiguration *)sessionConfiguration; // NSURLSession request call method, param sessionConfiguration must be same object with used to build NSURLSession.

- (void)registerMockHosts:(NSArray<NSString *> * (^)(void))hosts;
- (NSArray<NSString *> *)allMockHosts;

- (void)registerAction:(PDMockAction *)action forPath:(NSString *)path;
- (void)unregisterActionForPath:(NSString *)path;
- (void)unregisterAllActions;

- (NSArray<PDMockAction *> *)allActions;
- (PDMockAction * _Nullable)actionForPath:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
