//
// Created by luowei on 2019/11/21.
// Copyright (c) 2019 luowei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIWindow (LWShake)

- (BOOL)canBecomeFirstResponder;
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event;

@end