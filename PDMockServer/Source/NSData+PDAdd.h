//
//  NSData+PDAdd.h
//  PDMockServer
//
//  Created by liang on 2018/3/16.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (PDAdd)

- (NSDictionary *)toDictionary;

- (NSString *)toJSONString;

@end