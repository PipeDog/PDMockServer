//
//  PDMockServer.m
//  PDMockServer
//
//  Created by liang on 2018/3/16.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import "PDMockServer.h"
#import "PDMockURLProtocol.h"

#define Lock() dispatch_semaphore_wait(self->_lock, DISPATCH_TIME_FOREVER)
#define Unlock() dispatch_semaphore_signal(self->_lock)

@interface PDMockServer () {
    dispatch_semaphore_t _lock;
}

@property (nonatomic, strong) NSMutableArray<NSString *> *mockHosts;
@property (nonatomic, strong) NSMutableDictionary<NSString *, PDMockAction *> *actions;

@end

@implementation PDMockServer

+ (PDMockServer *)defaultServer {
    static PDMockServer *__defaultServer;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __defaultServer = [[self alloc] init];
    });
    return __defaultServer;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _lock = dispatch_semaphore_create(1);
    }
    return self;
}

- (void)switchEnabled:(BOOL)enabled {
    Lock();
    if (enabled) {
        [NSURLProtocol registerClass:[PDMockURLProtocol class]];
    } else {
        [NSURLProtocol unregisterClass:[PDMockURLProtocol class]];
    }
    Unlock();
}

- (void)switchEnabled:(BOOL)enabled forSessionConfiguration:(NSURLSessionConfiguration *)sessionConfiguration {
    if (!sessionConfiguration) return;

    Lock();
    NSMutableArray<Class> *protocolClasses = [NSMutableArray arrayWithArray:sessionConfiguration.protocolClasses];
    Class mockProtocolClass = [PDMockURLProtocol class];

    if (enabled) {
        [protocolClasses insertObject:mockProtocolClass atIndex:0];
    } else {
        [protocolClasses removeObject:mockProtocolClass];
    }
    sessionConfiguration.protocolClasses = [protocolClasses copy];
    Unlock();
}

- (void)registerMockHosts:(NSArray<NSString *> * (^)(void))hosts {
    if (!hosts) return;
    
    Lock();
    NSArray<NSString *> *mockHosts = hosts();

    for (NSString *host in mockHosts) {
        if ([self.mockHosts containsObject:host]) {
            continue;
        }
        [self.mockHosts addObject:host];
    }
    Unlock();
}

- (NSArray<NSString *> *)allMockHosts {
    Lock();
    NSArray<NSString *> *mockHosts = [self.mockHosts copy];
    Unlock();
    return mockHosts;
}

- (void)registerAction:(PDMockAction *)action forPath:(NSString *)path {
    if (!path) return;
    
    Lock();
    [self.actions setObject:action forKey:path];
    Unlock();
}

- (void)unregisterActionForPath:(NSString *)path {
    if (!path) return;
    
    Lock();
    [self.actions removeObjectForKey:path];
    Unlock();
}

- (void)unregisterAllActions {
    Lock();
    [self.actions removeAllObjects];
    Unlock();
}

- (NSArray<PDMockAction *> *)allActions {
    Lock();
    NSArray<PDMockAction *> *actions = [self.actions copy];
    Unlock();
    return actions;
}

- (PDMockAction *)actionForPath:(NSString *)path {
    if (!path) return nil;
    
    Lock();
    PDMockAction *action = self.actions[path];
    Unlock();
    return action;
}

#pragma mark - Getter Methods
- (NSMutableArray<NSString *> *)mockHosts {
    if (!_mockHosts) {
        _mockHosts = [NSMutableArray array];
    }
    return _mockHosts;
}

- (NSMutableDictionary<NSString *, PDMockAction *> *)actions {
    if (!_actions) {
        _actions = [NSMutableDictionary dictionary];
    }
    return _actions;
}

@end
