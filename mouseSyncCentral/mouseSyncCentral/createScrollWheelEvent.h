//
//  createScrollWheelEvent.h
//  mouseSync
//
//  Created by Chih-Hao on 2017/9/21.
//  Copyright © 2017年 Chih-Hao. All rights reserved.
//


#include <stdio.h>
#include <ApplicationServices/ApplicationServices.h>

void createScrollWheelEventY(float x) {
    CGEventRef upEvent = CGEventCreateScrollWheelEvent(
    NULL,
    kCGScrollEventUnitPixel, 2, x*5, 0 );
    CGEventPost(kCGHIDEventTap, upEvent);
    CFRelease(upEvent);
}

void createScrollWheelEventX(int y) {
        CGEventRef upEvent = CGEventCreateScrollWheelEvent(
                                                       NULL,
                                                       kCGScrollEventUnitPixel, 2, 0, y*5);
    CGEventPost(kCGHIDEventTap, upEvent);
    CFRelease(upEvent);
}
