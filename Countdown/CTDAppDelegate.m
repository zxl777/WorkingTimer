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

@property (weak) IBOutlet NSTextField *TimeLabel;
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



- (IBAction)GoalOK:(id)sender
{
    [self.GoalWindow close];
}

- (IBAction)TapedStartAgain:(id)sender
{
    [self TapedStart:nil];
}

-(void)StartTimer
{
//    self.countdownDate = [NSDate dateWithTimeIntervalSinceNow:3];
    self.countdownDate = [NSDate dateWithTimeIntervalSinceNow:PlanTime*60+1];
    self.timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
    IRQCount = 0;
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    [self.BreakTimeWindow close];
    
    [BlinkTimer invalidate];
    [self.TimeLabel setHidden:NO];
}

-(void)PauseTimer
{
    [self.timer invalidate];
    self.StartButton.title = @"▸";
    Paused = YES;
}

- (IBAction)SaveAndHiden:(id)sender
{
    [self SaveData];
    [self.WorkingTable close];
}


//
//<# 书签 #> 切换：⌃/ ⌃? 设置：m回车
//
-(void)ResumeTimer
{
    self.timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    self.StartButton.title = [NSString stringWithFormat:@"%d",count];
    Paused = NO;
}

-(void)StopTimer
{
    count ++;
    self.StartButton.title = [NSString stringWithFormat:@"%d",count];

    self.BreakInfo.stringValue = [NSString stringWithFormat:@"完成%d分钟聚焦",PlanTime ];
    [self.BreakTimeWindow setLevel: NSFloatingWindowLevel];
    [self.BreakTimeWindow makeKeyAndOrderFront:self];
    
//    [self.label setTextColor:[NSColor redColor]];
    [self ShowTime:PlanTime seconds:0];
//    if (count==0)
//        self.StartButton.title = @"▸";

    [self.timer invalidate];
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:9.0 target:self selector:@selector(HideBreakTimeWindow:) userInfo:nil repeats:NO];
    IRQCount = 0;
    
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    
    BlinkTimer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(BlinkTimerWindow:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:BlinkTimer forMode:NSRunLoopCommonModes];
}


- (void)BlinkTimerWindow:(NSTimer *)timer
{
    static bool flag = YES;
    [self.TimeLabel setHidden:flag];
    flag = !flag;
}


- (void)HideBreakTimeWindow:(NSTimer *)timer
{
    [self TapedBreakOK:nil];
}

- (void)applicationWillTerminate:(NSNotification *)notification;
{
    [self SaveData];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
//    self.countdownDate = [NSDate dateWithNaturalLanguageString:@"Tomorrow 2:00 PM"];
    Paused = NO;
    PlanTime = 25;
    [self.datePicker setMinDate:[NSDate date]];
    [self.datePicker setDateValue:self.countdownDate];
    [self.datePicker setTarget:self];
    [self.datePicker setAction:@selector(pickerChanged:)];
    
    
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
    [self ShowTime:PlanTime seconds:0];
//    [self.window setBackgroundColor:[NSColor clearColor]];
    self.StartButton.title = @"▸";
    
    BlinkTimer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(BlinkTimerWindow:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:BlinkTimer forMode:NSRunLoopCommonModes];
    
    
    self.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
//    [self timerFired:self.timer];
    
    
    NSString * doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * path = [doc stringByAppendingPathComponent:@"working25min.sqlite"];
    self.dbPath = path;
    NSLog(@"path = %@", path);

    NSFileManager * fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:self.dbPath] == NO)
    {
        // create it
        FMDatabase * db = [FMDatabase databaseWithPath:self.dbPath];
        [db open];
        [db close];
        [self CreateTable];
    }
    else
    {
        [self LoadData];
        self.CurrentGoalButton.title = self.CurrentGoal.stringValue;
    }
    count = 0;
}


-(void)CreateTable
{
    FMDatabase * db = [FMDatabase databaseWithPath:self.dbPath];
    [db open];
    NSString * sql = @"CREATE TABLE 'Work1' ('id' INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL , 'plan' VARCHAR(255), 'type' VARCHAR(1))"; //A,B,C,D - APlan ,BPlan ,CLan,DoingNow
    [db executeUpdate:sql];
    [db close];
}

-(void)CleanData
{
    FMDatabase * db = [FMDatabase databaseWithPath:self.dbPath];
    [db open];
    [db executeUpdate:@"delete from Work1"];
    [db close];
}

-(void)SaveData
{
    [self CleanData];
    FMDatabase * db = [FMDatabase databaseWithPath:self.dbPath];
    [db open];
    NSString * sql = @"insert into Work1 (plan, type) values(?, ?) ";
 
    NSMutableArray *APlanList = [NSMutableArray arrayWithArray:[self.APlanView.string componentsSeparatedByString:@"\n"]];
    for (id plan in APlanList)
    {
        [db executeUpdate:sql,plan,@"A"];
    }

    
    NSMutableArray *A7DaysPlanList = [NSMutableArray arrayWithArray:[self.A7DaysPlanView.string componentsSeparatedByString:@"\n"]];
    for (id plan in A7DaysPlanList)
    {
        [db executeUpdate:sql,plan,@"W"];
    }
    
    
    NSMutableArray *BPlanList = [NSMutableArray arrayWithArray:[self.BPlanView.string componentsSeparatedByString:@"\n"]];
    for (id plan in BPlanList)
    {
        [db executeUpdate:sql,plan,@"B"];
    }

    NSMutableArray *GoalList = [NSMutableArray arrayWithArray:[self.GoalView.string componentsSeparatedByString:@"\n"]];
    for (id plan in GoalList)
    {
        [db executeUpdate:sql,plan,@"C"];
    }
    
    [db executeUpdate:sql,self.CurrentGoal.stringValue,@"D"];
    
    
    [db close];
}

- (IBAction)TapedBreakOK:(id)sender
{
    BreaktimeStart = [ NSDate date];
    [self.BreakTimeWindow close];
}


-(void)LoadData
{
    FMDatabase * db = [FMDatabase databaseWithPath:self.dbPath];
    [db open];
    NSString * sql = @"select * from Work1 WHERE type = 'A'";
    FMResultSet * rs = [db executeQuery:sql];
    self.APlanView.string = @"";
    while ([rs next])
    {
        self.APlanView.string = [self.APlanView.string stringByAppendingString:[rs stringForColumn:@"plan"]];
        self.APlanView.string = [self.APlanView.string stringByAppendingString:@"\n"];
    }

    sql = @"select * from Work1 WHERE type = 'W'";
    rs = [db executeQuery:sql];
    self.BPlanView.string = @"";
    while ([rs next])
    {
        self.A7DaysPlanView.string = [self.A7DaysPlanView.string stringByAppendingString:[rs stringForColumn:@"plan"]];
        self.A7DaysPlanView.string = [self.A7DaysPlanView.string stringByAppendingString:@"\n"];
    }
    
    
    
    sql = @"select * from Work1 WHERE type = 'B'";
    rs = [db executeQuery:sql];
    self.BPlanView.string = @"";
    while ([rs next])
    {
        self.BPlanView.string = [self.BPlanView.string stringByAppendingString:[rs stringForColumn:@"plan"]];
        self.BPlanView.string = [self.BPlanView.string stringByAppendingString:@"\n"];
    }
    
    sql = @"select * from Work1 WHERE type = 'C'";
    rs = [db executeQuery:sql];
    self.GoalView.string = @"";
    while ([rs next])
    {
        self.GoalView.string = [self.GoalView.string stringByAppendingString:[rs stringForColumn:@"plan"]];
        self.GoalView.string = [self.GoalView.string stringByAppendingString:@"\n"];
    }
    
    
    sql = @"select * from Work1 WHERE type = 'D'";
    rs = [db executeQuery:sql];
    self.CurrentGoal.stringValue = @"";
    while ([rs next])
    {
        self.CurrentGoal.stringValue = [rs stringForColumn:@"plan"];
    }

    
    [db close];
}

//
//<# 书签 #> 切换：⌃/ ⌃? 设置：m回车 
//


- (IBAction)TapedSetGoal:(NSButton *)sender
{
    if (![self.TimeLabel.stringValue isEqualToString:[NSString stringWithFormat:@"%d:00",PlanTime ]])
        IRQCount ++;
    [self.WorkingTable makeKeyAndOrderFront:self];
    [self.BreakTimeWindow close];
}

//- (IBAction)TapedSetGoal:(NSMenuItem *)sender
//{
////    [self.WorkingTable setLevel: NSFloatingWindowLevel];
//    
//    
//}

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


- (IBAction)TapedStart:(NSButton *)sender
{
    [self SaveData];
    
    NSTimeInterval BreakTime = [ [ NSDate date ] timeIntervalSinceDate:BreaktimeStart];
    
    int breakMins = (int)BreakTime/60;

    

    if (breakMins>60*8)
    {
        count = 0;
    }
    
    if (breakMins <0)
    {
        count = 0;
        breakMins = 0;
    }
    

    if (count==0)
        self.StartButton.title = @"0";
    
    
    NSAlert *alert = [NSAlert alertWithMessageText: [NSString stringWithFormat:@"当前聚焦目标：\n\n《%@》",self.CurrentGoal.stringValue]
                                     defaultButton: @"好的，开始！"
                                   alternateButton: nil
                                       otherButton: nil
                         informativeTextWithFormat: [NSString stringWithFormat:@"刚才已休息了%d分钟",breakMins]];

    [alert runModal];

    [self StartTimer];
}

- (IBAction)TapedPlay:(id)sender
{
    if ([self.TimeLabel.stringValue isEqualToString:[NSString stringWithFormat:@"%d:00",PlanTime ]])
        [self TapedStart:nil];
    
    [self.WorkingTable close];
}

- (IBAction)TapGoalDone:(NSButton *)sender
{
    if ([self.CurrentGoal.stringValue length]!=0) //记录完成目标
    {
        self.GoalInfo.stringValue = [NSString stringWithFormat:@"\n🎉🎊😄 搞定 😄🎊🎉\n\%@\n\n",self.CurrentGoal.stringValue];
        NSString *cmdLine = [self.CommandLine.stringValue stringByReplacingOccurrencesOfString:@"%1" withString:self.CurrentGoal.stringValue];
//        NSLog(@"command = %@", [self runCommand:cmdLine]);
        
//        [self performSelector:@selector(runCommand:)  withObject:cmdLine afterDelay:0];
        
        [self performSelectorInBackground:@selector(runCommand:) withObject:cmdLine];
        
        self.GoalView.string = [NSString stringWithFormat:@"✅%@\n%@",self.CurrentGoal.stringValue,self.GoalView.string];
    
        self.CurrentGoal.stringValue = @"";
        
        NSMutableArray *APlanList = [NSMutableArray arrayWithArray:[self.APlanView.string componentsSeparatedByString:@"\n"]];
        [APlanList removeObjectAtIndex:0];
        self.APlanView.string = [APlanList componentsJoinedByString:@"\n"];
        
        self.CurrentGoalButton.title = self.CurrentGoal.stringValue;
    }
    
    self.APlanView.string = [self.APlanView.string stringByTrimmingCharactersInSet:
                                                                    [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([self.APlanView.string length]==0)
        return;
    NSMutableArray *APlanList = [NSMutableArray arrayWithArray:[self.APlanView.string componentsSeparatedByString:@"\n"]];
    self.CurrentGoal.stringValue = [APlanList objectAtIndex:0]; // 放大第一条
    
    self.CurrentGoalButton.title = self.CurrentGoal.stringValue;
    
    [self SaveData];
}

//- (BOOL)textView:(NSTextView *)aTextView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString

- (void)textDidChange:(NSNotification *)notification
{
    NSMutableArray *APlanList = [NSMutableArray arrayWithArray:[self.APlanView.string componentsSeparatedByString:@"\n"]];
    self.CurrentGoal.stringValue = [APlanList objectAtIndex:0]; // 放大第一条
    
    self.CurrentGoalButton.title = self.CurrentGoal.stringValue;
    
//    [self SaveData];
//    return YES;
}


-(NSDateComponents *)GetLeftTime
{
    NSUInteger flags = (NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit);
    NSDateComponents *components = [self.calendar components:flags fromDate:[NSDate date] toDate:self.countdownDate options:0];
    return components;
}

//一秒执行一次
- (void)timerFired:(NSTimer *)timer {
    
    NSInteger days, hours, minutes, seconds;
    
    NSDateComponents *components = [self GetLeftTime];
    
    days = [components day];
    hours = [components hour];
    minutes = [components minute];
    seconds = [components second];
    
    if (seconds <0)
    {
        [self StopTimer];
        return;
    }
    
    [self ShowTime:minutes seconds:seconds];
}

-(void)ShowTime:(long)minutes seconds:(long)seconds
{
    NSString *labelString = [NSString stringWithFormat:@"%02li:%02li", (long)minutes, (long)seconds];
    
    self.ProgressBar.maxValue = PlanTime;
    self.ProgressBar.doubleValue = PlanTime-minutes;
    
    [self.TimeLabel setStringValue:labelString];
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



-(NSString *)runCommand:(NSString *)commandToRun
{
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/sh"];
    
    NSArray *arguments = [NSArray arrayWithObjects:
                          @"-c" ,
                          [NSString stringWithFormat:@"%@", commandToRun],
                          nil];
    NSLog(@"run command: %@",commandToRun);
    [task setArguments: arguments];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data;
    data = [file readDataToEndOfFile];
    
    NSString *output;
    output = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    
    NSLog(@"command line = %@ \n%@", commandToRun,output);
    return output;
}


@end
