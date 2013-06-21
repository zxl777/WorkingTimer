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
    self.countdownDate = [NSDate dateWithNaturalLanguageString:@"June 21, 2013 2:00 PM CDT"];
    //self.countdownDate = [NSDate dateWithNaturalLanguageString:@"Tomorrow 2:00 PM"];
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
    
    self.timerWindowVisible = NO;
    self.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    [self timerFired:self.timer];
    
}

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
    
    NSString *dayString = (days == 1) ? @"day" : @"days";
    NSString *labelString = (days == 0) ? [NSString stringWithFormat:@"%li:%02li:%02li", (long)hours, (long)minutes, (long)seconds] : [NSString stringWithFormat:@"%li %@, %li:%02li:%02li", (long)days, dayString, (long)hours, (long)minutes, (long)seconds];
    
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
        [self.window orderOut:nil];
    } else {
        [item setTitle:kHideTimerPanelString];
        [self.window makeKeyAndOrderFront:nil];
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
