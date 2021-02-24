//
//  PDHooker.m
//  PDMockServer
//
//  Created by liang on 2018/4/17.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import "PDHooker.h"
#import <objc/runtime.h>

void class_exchangeInstanceMethod(Class cls, SEL replacedSel, SEL replacementSel) {
    Method replacedMethod = class_getInstanceMethod(cls, replacedSel);
    Method replacementMethod = class_getInstanceMethod(cls, replacementSel);
    
    BOOL success = class_addMethod(cls,
                                   replacedSel,
                                   method_getImplementation(replacementMethod),
                                   method_getTypeEncoding(replacementMethod));
    if (success) {
        class_replaceMethod(cls,
                            replacementSel,
                            method_getImplementation(replacedMethod),
                            method_getTypeEncoding(replacedMethod));
    } else {
        method_exchangeImplementations(replacedMethod, replacementMethod);
    }
}

void class_exchangeClassMethod(Class cls, SEL replacedSel, SEL replacementSel) {
    Class metaClass = object_getClass(cls);
    class_exchangeInstanceMethod(metaClass, replacedSel, replacementSel);
}
