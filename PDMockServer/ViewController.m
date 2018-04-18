//
//  ViewController.m
//  PDMockServer
//
//  Created by liang on 2018/3/16.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import "ViewController.h"
#import "PDMockServer.h"
#import "PDDataProcess.h"
#import "PDMockURLProtocol.h"

@interface ViewController () <NSURLSessionDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [PDMockServer.defaultServer registerMockHosts:^NSArray<NSString *> * _Nonnull{
        return @[@"https://www.baidu.com",
                 @"https://segmentfault.com",
                 @"http://192.168.50.23"];
    }];
    
    [[PDMockServer defaultServer] registerAction:[PDMockAction actionWithResponseHandler:^PDMockResponse * _Nonnull(__kindof NSURLRequest * _Nullable request) {
        return [PDMockResponse make:^(PDMockResponse * _Nonnull response) {
            response.dict = @{@"name": @"liang",
                              @"age": @26};
            response.error = nil;
            response.delay = 1.f;
        }];
    }] forPath:@"/a/1190000002933776"];
}

- (IBAction)sendRequestByURLSession:(id)sender {
    NSLog(@"%s", __func__);

    NSURL *URL = [NSURL URLWithString:@"https://segmentfault.com/a/1190000002933776"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionTask *sessionTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"error = %@", error);
        } else {
            NSLog(@"response = (%@), dict = (%@)", response, [data toDictionary]);
        }
    }];
    [sessionTask resume];
}

- (IBAction)sendRequestByURLConnection:(id)sender {
    NSLog(@"%s", __func__);
    
    NSURL *URL = [NSURL URLWithString:@"https://segmentfault.com/a/1190000002933776"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        if (connectionError) {
            NSLog(@"error = %@", connectionError);
        } else {
            NSLog(@"response = (%@), dict = (%@)", response, [data toDictionary]);
        }
    }];
}

- (IBAction)didClickEnableButton:(id)sender {
    [[PDMockServer defaultServer] switchEnabled:YES];
}

- (IBAction)didClickUnenableButton:(id)sender {
    [[PDMockServer defaultServer] switchEnabled:NO];
}

@end
