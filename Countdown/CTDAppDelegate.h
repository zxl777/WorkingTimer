//
//  CTDAppDelegate.h
//  Countdown
//
//  Created by Chris Cieslak on 6/18/13.
//  Copyright (c) 2013 Stand Alone. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <FMDatabase.h>

@interface CTDAppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>
{
    bool ShowOnTop;
    int count;
    bool Paused;
    
    int IRQCount;
    NSDate *BreaktimeStart;
}

@property (unsafe_unretained) IBOutlet NSWindow *GoalWindow;
@property (weak) IBOutlet NSTextField *GoalInfo;

@property (nonatomic, retain) NSString * dbPath;
@property (assign) IBOutlet NSWindow *window;

@property (unsafe_unretained) IBOutlet NSWindow *BreakTimeWindow;
@property (weak) IBOutlet NSTextField *BreakInfo;


@property (strong) IBOutlet NSWindow *WorkingTable;

- (IBAction)quit:(id)sender;
- (IBAction)showHidePanel:(id)sender;
- (IBAction)showDatePanel:(id)sender;

@property (weak) IBOutlet NSTextField *CurrentGoal;

@property (weak) IBOutlet NSButton *CurrentGoalButton;


@property (weak) IBOutlet NSButton *StartButton;

@property (unsafe_unretained) IBOutlet NSTextView *APlanView;


@property (unsafe_unretained) IBOutlet NSTextView *A7DaysPlanView;

@property (unsafe_unretained) IBOutlet NSTextView *GoalView;

@property (unsafe_unretained) IBOutlet NSTextView *BPlanView;

@end
