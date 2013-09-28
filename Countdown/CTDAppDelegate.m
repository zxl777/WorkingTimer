//
//  CTDAppDelegate.m
//  Countdown
//
//  Created by Chris Cieslak on 6/18/13.
//  Copyright (c) 2013 Stand Alone. All rights reserved.
//

#import "CTDAppDelegate.h"

NSString * const kShowTimerPanelString = @"Show Timer Panel";
NSString * const kHideTimerPanelString = @"Hide Timer Panel";
NSString * const kDoneString = @"Done!";


@interface CTDAppDelegate ()

@property (weak) IBOutlet NSTextField *label;
@property (weak) IBOutlet NSMenu *menu;
@property (weak) IBOutlet NSWindow *datePickerPanel;
@property (weak) IBOutlet NSDatePicker *datePicker;

@property (strong) NSCalendar *calendar;
@property (strong) NSTimer *timer;
@property (strong) NSDate *countdownDate;
@property (strong) NSStatusItem *statusItem;
@property (assign) BOOL timerWindowVisible;

@end

@implementation CTDAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
//    self.countdownDate = [NSDate dateWithNaturalLanguageString:@"Tomorrow 2:00 PM"];
    self.countdownDate = [NSDate dateWithTimeIntervalSinceNow:25*60];
    [self.datePicker setMinDate:[NSDate date]];
    [self.datePicker setDateValue:self.countdownDate];
    [self.datePicker setTarget:self];
    [self.datePicker setAction:@selector(pickerChanged:)];
    
    self.timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    
    NSStatusBar *bar = [NSStatusBar systemStatusBar];
    self.statusItem = [bar statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setHighlightMode:YES];
    self.statusItem.menu = self.menu;
    
    self.timerWindowVisible = YES;
    [self.window setLevel: NSFloatingWindowLevel];
    [self.window setOpaque:NO];
    [self.window setAlphaValue:0.6];
    
    ShowOnTop = NO;
    [self TapedWindow:nil];
//    [self.window setBackgroundColor:[NSColor clearColor]];
    
    
    self.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    [self timerFired:self.timer];
    
}

- (IBAction)TapedSetGoal:(NSMenuItem *)sender
{
    [self.WorkingTable setLevel: NSFloatingWindowLevel];
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
    self.CurrentGoalButton.title =self.CurrentGoal.stringValue;
}

- (IBAction)TapedWindow:(NSButton *)sender
{
    CGRect frame = self.window.frame;
    ShowOnTop = !ShowOnTop;
    if (ShowOnTop)
        frame.origin.y = [NSScreen mainScreen].frame.size.height-frame.size.height-24;
    else
        frame.origin.y = 0;
    
    
    [self.window setFrame:frame display:YES];
}


- (IBAction)TapGoalDone:(NSButton *)sender
{
    if ([self.CurrentGoal.stringValue length]!=0) //记录完成目标
    {
        self.GoalView.string = [NSString stringWithFormat:@"%@\n%@",self.GoalView.string,self.CurrentGoal.stringValue];
    
        self.CurrentGoal.stringValue = @"";
    }

    
    self.APlanView.string = [self.APlanView.string stringByTrimmingCharactersInSet:
                                                                    [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([self.APlanView.string length]==0)
        return;
    NSMutableArray *APlanList = [NSMutableArray arrayWithArray:[self.APlanView.string componentsSeparatedByString:@"\n"]];
    self.CurrentGoal.stringValue = [APlanList lastObject]; // 加子弹
    
    [APlanList removeLastObject]; //弹夹下一个子弹
    self.APlanView.string = [APlanList componentsJoinedByString:@"\n"];
}



//一秒执行一次
- (void)timerFired:(NSTimer *)timer {
    
    NSInteger days, hours, minutes, seconds;
    
    NSUInteger flags = (NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit);
    NSDateComponents *components = [self.calendar components:flags fromDate:[NSDate date] toDate:self.countdownDate options:0];
    
    days = [components day];
    hours = [components hour];
    minutes = [components minute];
    seconds = [components second];
    
    if (seconds < 0) {
        [self.label setTextColor:[NSColor redColor]];
        [self.label setStringValue:kDoneString];
        [self.statusItem setTitle:kDoneString];
        [self.timer invalidate];
        return;
    }
    
//    NSString *dayString = (days == 1) ? @"day" : @"days";
//    NSString *labelString = (days == 0) ? [NSString stringWithFormat:@"%li:%02li:%02li", (long)hours, (long)minutes, (long)seconds] : [NSString stringWithFormat:@"%li %@, %li:%02li:%02li", (long)days, dayString, (long)hours, (long)minutes, (long)seconds];

    NSString *labelString = [NSString stringWithFormat:@"%02li:%02li", (long)minutes, (long)seconds];

    
    [self.label setStringValue:labelString];
    [self.statusItem setTitle:labelString];
    
}

- (void)windowWillClose:(NSNotification *)notification {

    NSWindow *window = [notification object];
    if (window == self.window) {
        self.timerWindowVisible = NO;
        NSMenuItem *item = [self.statusItem.menu itemAtIndex:0];
        [item setTitle:kShowTimerPanelString];
    }

}

- (IBAction)quit:(id)sender {
    [[NSApplication sharedApplication] terminate:self];
}

- (IBAction)showHidePanel:(id)sender {
    NSMenuItem *item = (NSMenuItem *)sender;
    if (self.timerWindowVisible) {
        [item setTitle:kShowTimerPanelString];
//        [self.window setLevel:NSStatusWindowLevel];
//        [self.window orderOut:nil];
        [[self window] setLevel: NSFloatingWindowLevel];
    } else {
        [item setTitle:kHideTimerPanelString];
//        [self.window makeKeyAndOrderFront:nil];
//        [self.window setLevel:NSStatusWindowLevel];
        [[self window] setLevel: NSFloatingWindowLevel];
    }
    self.timerWindowVisible = !self.timerWindowVisible;
}

- (IBAction)showDatePanel:(id)sender {
    [self.datePickerPanel makeKeyAndOrderFront:nil];
}

- (void)pickerChanged:(id)sender {
    self.countdownDate = [self.datePicker dateValue];
    [self timerFired:self.timer];
}
@end
