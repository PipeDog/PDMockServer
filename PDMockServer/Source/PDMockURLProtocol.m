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
    NSString *host = request.URL.host;
    BOOL registeredHost = NO;
    NSArray<NSString *> *allMockHosts = [PDMockServer.defaultServer allMockHosts];
    
    for (NSString *mockHost in allMockHosts) {
        if ([mockHost rangeOfString:host].location != NSNotFound) {
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
    NSData *data = mockResponse.data;
    NSTimeInterval delay = mockResponse.delay;

    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:request.URL
                                                              statusCode:(data ? 200 : 400)
                                                             HTTPVersion:nil
                                                            headerFields:nil];
    dispatch_block_t perform = ^{
        if (data) {
            [client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
            [client URLProtocol:self didLoadData:data];
            [client URLProtocolDidFinishLoading:self];
        } else {
            NSError *error = [NSError errorWithDomain:@"PDMockServerNoResponseData" code:-100 userInfo:@{@"PDErrorFailingURLStringKey": request.URL.absoluteString, @"PDErrorFailingReason": @"No response data."}];
            [client URLProtocol:self didFailWithError:error];
        }
    };
    
    if (delay > 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), perform);
    } else {
        perform();
    }
}

- (void)stopLoading {
    _action = nil;
}

@end
