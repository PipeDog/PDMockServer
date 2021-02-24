//
//  PDMockResponse.h
//  PDMockServer
//
//  Created by liang on 2018/3/16.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PDMockResponse <NSObject>

@property (nonatomic, strong, nullable) NSData *data; ///< Response data.
@property (nonatomic, copy, nullable) NSString *path; ///< Response file local path.
@property (nonatomic, copy, nullable) NSDictionary *dict; ///< Response data dict.
@property (nonatomic, copy, nullable) NSString *JSONString; ///< Response data json string.
@property (nonatomic, strong, nullable) NSError *error; ///< Response error.
@property (nonatomic, assign) NSTimeInterval delay; ///< Response delay (seconds), default is 0s.

@end

@interface PDMockResponse : NSObject <PDMockResponse>

+ (instancetype)responseWithBuilder:(void (^)(id<PDMockResponse> builder))block;

@end

NS_ASSUME_NONNULL_END
