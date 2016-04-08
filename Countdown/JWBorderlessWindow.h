//
//  JWBorderlessWindow.h
//  JWBorderlessWindowTest
//
//  Created by Xu Jiwei on 12-9-13.
//  Copyright (c) 2012年 Xu Jiwei. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface JWBorderlessWindow : NSWindow {
    BOOL            mouseDraggedForMoveOrResize;
    BOOL            mouseDownInResizeArea;
    NSPoint         mouseDownLocation;
    NSRect          mouseDownWindowFrame;
}

@end
