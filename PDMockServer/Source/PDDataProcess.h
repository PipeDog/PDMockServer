//
//  PDDataProcess.h
//  PDMockServer
//
//  Created by liang on 2018/3/19.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (PDAdd)

- (NSString * _Nullable)toJSONString;

- (NSData * _Nullable)toData;

@end

@interface NSString (PDAdd)

- (NSDictionary * _Nullable)toDictionary;

- (NSData * _Nullable)toData;

@end

@interface NSData (PDAdd)

- (NSDictionary * _Nullable)toDictionary;

- (NSString * _Nullable)toJSONString;

@end

NS_ASSUME_NONNULL_END
