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

void mouse_left_drag_to(float x, float y) {
    
    /**
     * create a new Quartz mouse event.
     * params:
     * @source : CGEventSourceRef
     * @mouseType : CGEventType
     * @mouseCursorPosition : CGPoint
     * @mouseButton : CGMouseButton
     */
    CGEventRef left_drag_event = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseDragged, CGPointMake(x, y), 0);
    
    /**
     * post a Quartz event into the event stream at a specified location.
     * params:
     * @tap : CGEventTapLocation
     * @event : CGEventRef
     */
    CGEventPost(kCGHIDEventTap, left_drag_event);
    
    /**
     * release a Quartz event
     */
    CFRelease(left_drag_event);
}
