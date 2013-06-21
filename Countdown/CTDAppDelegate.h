//
//  CTDAppDelegate.h
//  Countdown
//
//  Created by Chris Cieslak on 6/18/13.
//  Copyright (c) 2013 Stand Alone. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CTDAppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>

@property (assign) IBOutlet NSWindow *window;

- (IBAction)quit:(id)sender;
- (IBAction)showHidePanel:(id)sender;
- (IBAction)showDatePanel:(id)sender;

@end
