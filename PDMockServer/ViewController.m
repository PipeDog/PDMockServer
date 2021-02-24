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
#import <AFNetworking/AFNetworking.h>

@interface ViewController () <NSURLSessionDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self configMockServer];
}

- (void)configMockServer {
    [PDMockServer.defaultServer registerMockHosts:^NSArray<NSString *> * _Nonnull{
        return @[@"https://www.baidu.com",
                 @"https://segmentfault.com",
                 @"http://192.168.50.23"];
    }];
    
    [[PDMockServer defaultServer] registerAction:[PDMockAction actionWithResponseHandler:^PDMockResponse * _Nonnull(__kindof NSURLRequest * _Nullable request) {
        return [PDMockResponse responseWithBuilder:^(id<PDMockResponse>  _Nonnull builder) {
            builder.path = [[NSBundle mainBundle] pathForResource:@"mock" ofType:@"json"];
            builder.error = nil;
            builder.delay = 1.f;
        }];
    }] forPath:@"/a/1190000002933776"];
}

#pragma mark - UITableView Delegate && DataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reUse"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reUse"];
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = @"switch YES";
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"switch NO";
    } else if (indexPath.row == 2) {
        cell.textLabel.text = @"URLSession";
    } else if (indexPath.row == 3) {
        cell.textLabel.text = @"URLConnection";
    } else if (indexPath.row == 4) {
        cell.textLabel.text = @"AFNetWorking";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        [[PDMockServer defaultServer] switchEnabled:YES];
    } else if (indexPath.row == 1) {
        [[PDMockServer defaultServer] switchEnabled:NO];
    } else if (indexPath.row == 2) {
        NSURL *URL = [NSURL URLWithString:@"https://segmentfault.com/a/1190000002933776"];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        
        NSURLSessionTask *sessionTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                NSLog(@"error = %@", error);
            } else {
                NSLog(@"response = (%@), dict = (%@)", response, PDValueToJSONObject(data));
            }
        }];
        [sessionTask resume];
    } else if (indexPath.row == 3) {
        NSURL *URL = [NSURL URLWithString:@"https://segmentfault.com/a/1190000002933776"];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
            if (connectionError) {
                NSLog(@"error = %@", connectionError);
            } else {
                NSLog(@"response = (%@), dict = (%@)", response, PDValueToJSONObject(data));
            }
        }];
    } else if (indexPath.row == 4) {
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        [manager GET:@"https://segmentfault.com/a/1190000002933776" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSLog(@"result = %@", result);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"error = %@", error);
        }];
    }
}

@end
