//
// Created by luowei on 2019/11/21.
// Copyright (c) 2019 luowei. All rights reserved.
//

#import "UIWindow+LWShake.h"


@implementation UIWindow (LWShake)

- (BOOL)canBecomeFirstResponder {//默认是NO，所以得重写此方法，设成YES
    return YES;
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    NSLog(@"shake shake shake shake shake shake shake shake shake shake");
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event {
}


@end