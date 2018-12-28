//
//  PDMockServer.m
//  PDMockServer
//
//  Created by liang on 2018/3/16.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import "PDMockServer.h"
#import "PDMockURLProtocol.h"
#import "PDHooker.h"
#include <pthread.h>

#define Lock() pthread_mutex_lock(&self->_lock)
#define Unlock() pthread_mutex_unlock(&self->_lock)

@interface NSURLSessionConfiguration (PDAdd)

+ (void)switchEnabled:(BOOL)enabled;

@end

@interface PDMockServer () {
    pthread_mutex_t _lock;
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

- (void)dealloc {
    pthread_mutex_destroy(&self->_lock);
}

- (instancetype)init {
    self = [super init];
    if (self) {
        pthread_mutex_init(&self->_lock, NULL);
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
    
    [NSURLSessionConfiguration switchEnabled:enabled];
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

@implementation NSURLSessionConfiguration (PDAdd)

static BOOL kMockEnabled = NO;

+ (void)switchEnabled:(BOOL)enabled {
    if (kMockEnabled == enabled) return;
    
    kMockEnabled = enabled;
    Class cls = [NSURLSessionConfiguration class];
    
    class_exchangeClassMethod(cls,
                              @selector(defaultSessionConfiguration),
                              @selector(pd_defaultSessionConfiguration));
    class_exchangeClassMethod(cls,
                              @selector(ephemeralSessionConfiguration),
                              @selector(pd_ephemeralSessionConfiguration));
    class_exchangeClassMethod(cls,
                              @selector(backgroundSessionConfigurationWithIdentifier:),
                              @selector(pd_backgroundSessionConfigurationWithIdentifier:));
}

+ (NSURLSessionConfiguration *)pd_defaultSessionConfiguration {
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration pd_defaultSessionConfiguration];
    [PDMockServer.defaultServer switchEnabled:YES forSessionConfiguration:sessionConfiguration];
    return sessionConfiguration;
}

+ (NSURLSessionConfiguration *)pd_ephemeralSessionConfiguration {
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration pd_ephemeralSessionConfiguration];
    [PDMockServer.defaultServer switchEnabled:YES forSessionConfiguration:sessionConfiguration];
    return sessionConfiguration;
}

+ (NSURLSessionConfiguration *)pd_backgroundSessionConfigurationWithIdentifier:(NSString *)identifier {
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration pd_backgroundSessionConfigurationWithIdentifier:identifier];
    [PDMockServer.defaultServer switchEnabled:YES forSessionConfiguration:sessionConfiguration];
    return sessionConfiguration;
}

@end
