//
//  PDMockURLProtocol.m
//  PDMockServer
//
//  Created by liang on 2018/3/16.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import "PDMockURLProtocol.h"
#import "PDMockServer.h"
#import "PDMockResponse.h"

static NSString *const kProtocolKey = @"kProtocolKey";

@interface PDMockURLProtocol ()

@property (nonatomic, strong) PDMockAction *action;

@end

@implementation PDMockURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if ([NSURLProtocol propertyForKey:kProtocolKey inRequest:request]) {
        return NO;
    }
    // Verify that host is registered.
    BOOL registeredHost = NO;
    NSArray<NSString *> *allMockHosts = [PDMockServer.defaultServer allMockHosts];
    
    for (NSString *mockHost in allMockHosts) {
        if ([request.URL.absoluteString hasPrefix:mockHost]) {
            registeredHost = YES;
            break;
        }
    }
    if (!registeredHost) return NO;
    
    // Verify the request is registered.
    PDMockAction *action = [PDMockServer.defaultServer actionForPath:request.URL.path];
    // Check condition.
    return action.condition(request);
}

- (instancetype)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id<NSURLProtocolClient>)client {
    self = [super initWithRequest:request cachedResponse:cachedResponse client:client];
    if (self) {
        _action = [[PDMockServer defaultServer] actionForPath:request.URL.path];
    }
    return self;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (void)startLoading {
    NSMutableURLRequest *request = [self.request mutableCopy];
    [NSURLProtocol setProperty:@(YES) forKey:kProtocolKey inRequest:request];

    id<NSURLProtocolClient> client = self.client;
    
    PDMockResponse *mockResponse = self.action.handler(request);
    NSData *mockData = mockResponse.data;
    NSTimeInterval mockDelay = mockResponse.delay;
    NSError *mockError = mockResponse.error;

    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:request.URL
                                                              statusCode:(mockData ? 200 : 400)
                                                             HTTPVersion:nil
                                                            headerFields:nil];
    dispatch_block_t perform = ^{
        if (mockError) {
            [client URLProtocol:self didFailWithError:mockError];
        } else if (mockData) {
            [client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
            [client URLProtocol:self didLoadData:mockData];
            [client URLProtocolDidFinishLoading:self];
        } else {
            NSDictionary *userInfo = @{@"PDErrorFailingURLStringKey": request.URL.absoluteString,
                                       @"PDErrorFailingReason": @"No response data."};
            NSError *error = [NSError errorWithDomain:@"PDMockServerNoResponseData" code:-100 userInfo:userInfo];
            [client URLProtocol:self didFailWithError:error];
        }
    };
    
    if (mockDelay > 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(mockDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), perform);
    } else {
        perform();
    }
}

- (void)stopLoading {
    _action = nil;
}

@end
