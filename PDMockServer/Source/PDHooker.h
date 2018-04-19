//
//  PDHooker.h
//  PDMockServer
//
//  Created by liang on 2018/4/17.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT
void class_exchangeInstanceMethod(Class cls, SEL originalSEL, SEL replaceSEL);

FOUNDATION_EXPORT
void class_exchangeClassMethod(Class cls, SEL originalSEL, SEL replaceSEL);
