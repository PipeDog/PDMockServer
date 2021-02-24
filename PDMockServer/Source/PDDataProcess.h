//
//  PDDataProcess.h
//  PDMockServer
//
//  Created by liang on 2018/3/19.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT id _Nullable PDValueToJSONObject(id value);
FOUNDATION_EXPORT NSData * _Nullable PDValueToData(id value);
FOUNDATION_EXPORT NSString * _Nullable PDValueToJSONText(id value);

NS_ASSUME_NONNULL_END
