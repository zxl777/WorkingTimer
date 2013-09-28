//
//  CTDAppDelegate.h
//  Countdown
//
//  Created by Chris Cieslak on 6/18/13.
//  Copyright (c) 2013 Stand Alone. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CTDAppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>
{
    bool ShowOnTop;
}

@property (assign) IBOutlet NSWindow *window;


@property (strong) IBOutlet NSWindow *WorkingTable;

- (IBAction)quit:(id)sender;
- (IBAction)showHidePanel:(id)sender;
- (IBAction)showDatePanel:(id)sender;

@property (weak) IBOutlet NSTextField *CurrentGoal;

@property (weak) IBOutlet NSButton *CurrentGoalButton;

@property (unsafe_unretained) IBOutlet NSTextView *APlanView;

@property (unsafe_unretained) IBOutlet NSTextView *GoalView;

@property (unsafe_unretained) IBOutlet NSTextView *BPlanView;

@end
