/*
 MenuCal - AppDelegate.m
 
 History:
 
 v. 1.0.0 (11/05/2018) - Initial version
 v. 1.0.1 (11/07/2018) - Save user preferences
 v. 1.0.2 (11/12/2018) - Add support for launching at login time
 
 Copyright (c) 2018 Sriranga R. Veeraraghavan <ranga@calalum.org>
 
 Permission is hereby granted, free of charge, to any person obtaining
 a copy of this software and associated documentation files (the "Software"),
 to deal in the Software without restriction, including without limitation
 the rights to use, copy, modify, merge, publish, distribute, sublicense,
 and/or sell copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included
 in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 DEALINGS IN THE SOFTWARE.
 */

#import <ServiceManagement/ServiceManagement.h>
#import "AppDelegate.h"

/* Constants */

/* User preferences */

NSString *gPrefShowDate = @"ShowDate";
NSString *gPrefShowDateShortStyle = @"ShowDateShortStyle";
NSString *gPrefShowDay = @"ShowDay";
NSString *gPrefShowYear = @"ShowYear";
NSString *gPrefShowTime = @"ShowTime";
NSString *gPrefLaunchAtLogin = @"LaunchAtLogin";

/* Menu image file name */

NSString *gMenuImage = @"MenuCal.png";

/* Help App Bundle Name */

NSString *gHelperAppBundle = @"org.calalum.ranga.MenuCalLaunchAtLoginHelper";

NSString *gMsgTerminate = @"Terminate";

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (strong, nonatomic) NSStatusItem *statusItem;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:
    (NSNotification *)aNotification
{
    NSArray *apps = nil;
    NSUserDefaults* defaults = nil;
    BOOL startedAtLogin = FALSE;
    
    /*
        Create the status item and set its icon:
        http://preserve.mactech.com/articles/mactech/Vol.22/22.02/Menulet/index.html
     
        See also:
        http://www.sonsothunder.com/devres/livecode/tutorials/StatusMenu.html
     */
    
    self.statusItem = [[NSStatusBar systemStatusBar]
                       statusItemWithLength: NSVariableStatusItemLength];
    [self.statusItem setHighlightMode: YES];
    [self.statusItem setMenu: MCMenu];

    /* Get the user's preferences for displaying the date, day, and time */

    defaults = [NSUserDefaults standardUserDefaults];
    
    showDate = [defaults boolForKey: gPrefShowDate];
    showDateShortStyle = [defaults boolForKey: gPrefShowDateShortStyle];
    showDay = [defaults boolForKey: gPrefShowDay];
    showYear = [defaults boolForKey: gPrefShowYear];
    showTime = [defaults boolForKey: gPrefShowTime];
    launchAtLogin = [defaults boolForKey: gPrefLaunchAtLogin];
    
    /*
        Configure showColon to true so that the colon is initially seen when the
        time is displayed in the menu bar
     */
    
    showColon = TRUE;
    
    /* Set the actions for show date and show time menu items */
    
    [MCMenuItemShowDateInMenuBar setAction: @selector(actionShowDate:)];
    [MCMenuItemShowDateShortStyleInMenuBar setAction:
     @selector(actionShowDateShortStyle:)];
    [MCMenuItemShowDayInMenuBar setAction: @selector(actionShowDay:)];
    [MCMenuItemShowYearInMenuBar setAction: @selector(actionShowYear:)];
    [MCMenuItemShowTimeInMenuBar setAction: @selector(actionShowTime:)];
    [MCMenuItemLaunchAtLogin setAction: @selector(actionLaunchAtLogin:)];
    
    /*
        Set the state of (checkmark) of the menu items based on the user's
        preferences
     */
    
    [MCMenuItemShowDateInMenuBar setState: (showDate ? NSOnState : NSOffState)];
    [MCMenuItemShowDateShortStyleInMenuBar setState: (showDateShortStyle ? NSOnState : NSOffState)];
    [MCMenuItemShowDayInMenuBar setState: (showDay ? NSOnState : NSOffState)];
    [MCMenuItemShowYearInMenuBar setState: (showYear ? NSOnState : NSOffState)];
    [MCMenuItemShowTimeInMenuBar setState: (showTime ? NSOnState : NSOffState)];
    [MCMenuItemLaunchAtLogin setState: (launchAtLogin ? NSOnState : NSOffState)];
    
    /*
        Enable / disable the menu bar items:
        https://stackoverflow.com/questions/4524294/disabled-nsmenuitem#4683010
     
        Note: this works b/c the menu is marked as not auto-enable in MainMenu.xib

        Rules:
        1. "Show Date", "Show Time", "Launch At Login", and "Quit" should always
           be enabled.
        2. "Show Day", "Show Year", and "Short Style" should be enabled only if
           the user wants the date to be shown in the menu bar
        3. The static date should always be disabled.
     */
    
    [MCMenuItemShowDateInMenuBar setEnabled: TRUE];
    [MCMenuItemShowTimeInMenuBar setEnabled: TRUE];
    [MCMenuItemLaunchAtLogin setEnabled: TRUE];
    [MCMenuItemQuit setEnabled: TRUE];
    
    [MCMenuItemShowDayInMenuBar setEnabled: showDate];
    [MCMenuItemShowYearInMenuBar setEnabled: showDate];
    [MCMenuItemShowDateShortStyleInMenuBar setEnabled: showDate];

    [MCMenuItemDate setEnabled: FALSE];

    /* Enable the update timer */
    
    [self actionTimer];

    /* Create a new datepicker in graphic mode without a border */
    
    MCDatePicker = [[MenuCalDatePicker alloc] initWithFrame: NSMakeRect(0, 0, 140, 148)];
    [MCDatePicker setDatePickerStyle: NSClockAndCalendarDatePickerStyle];
    [MCDatePicker setBordered: FALSE];

    /* Set the date */
    
    [self updateDate];
    
    /*
        Make the datepicker the view for the menuitem:
        https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/MenuList/Articles/ViewsInMenuItems.html
    */

    [MCMenuItemDatePicker setView: MCDatePicker];
    
    apps = [[NSWorkspace sharedWorkspace] runningApplications];
    for (NSRunningApplication *app in apps)
    {
        if ([app.bundleIdentifier isEqualToString: gHelperAppBundle])
        {
            startedAtLogin = TRUE;
            break;
        }
    }

    if (startedAtLogin)
    {
        [[NSDistributedNotificationCenter defaultCenter]
         postNotificationName: gMsgTerminate
         object: [[NSBundle mainBundle] bundleIdentifier]];
    }
}

- (void)awakeFromNib: (NSNotification *)aNotification
{
}

- (void)applicationWillTerminate: (NSNotification *)aNotification
{
}

/*
    actionTimer - actions to take when the timer fires:
    https://stackoverflow.com/questions/1031554/nstimer-doesnt-stop
 */

- (void)actionTimer
{
    /* The timer duration, default is 60s */
    
    double duration = 60.0;
    
    /* If time and date are both shown, the duration should be 1.5s.
       If only time is shown , it should be 2s. */
    
    if (showTime)
    {
        duration = (showDate ? 1.5 : 2.0);
    }

    /* Update the menu bar */
    
    [self updateStatusItemTitle];
    
    /* Start a new timer */
    
    MCTimer = [NSTimer scheduledTimerWithTimeInterval: duration
                                               target: self
                                             selector: @selector(actionTimer)
                                             userInfo: nil
                                              repeats: NO];
}

/* actionShowDate - actions to take when the show date menu item is clicked */

- (void)actionShowDate: (id)sender
{
    /* Toggle the setting for whether the date should be shown in the menubar */

    showDate = !showDate;

    /* Update the user's preferences */
    
    [[NSUserDefaults standardUserDefaults] setBool: showDate
                                            forKey: gPrefShowDate];
    
    /*
        Show a checkmark before this menu item if the date should be
        shown in the menubar:
        https://stackoverflow.com/questions/2176639/how-to-add-a-check-mark-to-an-nsmenuitem
     */
    
    [MCMenuItemShowDateInMenuBar setState: (showDate ? NSOnState : NSOffState)];

    /*
        Enable / disable the show day and show date in short style menu items
        based on whether the date is displayed
     */
    
    [MCMenuItemShowDayInMenuBar setEnabled: showDate];
    [MCMenuItemShowDateShortStyleInMenuBar setEnabled: showDate];
    
    /* Update the title of this menu item by firing the current timer */
    
    [MCTimer fire];
 }

/*
    actionShowDate - actions to take when the show date in short style menu
                     item is clicked
 */

- (void)actionShowDateShortStyle:(id)sender
{
    /* Toggle the setting for whether the day should be shown in the menubar */
    
    showDateShortStyle = !showDateShortStyle;

    /* Update the user's preferences */
    
    [[NSUserDefaults standardUserDefaults] setBool: showDateShortStyle
                                            forKey: gPrefShowDateShortStyle];

    /*
        Show a checkmark before this menu item if the date should be
        shown in short style:
        https://stackoverflow.com/questions/2176639/how-to-add-a-check-mark-to-an-nsmenuitem
     */
    
    [MCMenuItemShowDateShortStyleInMenuBar setState:
     (showDateShortStyle ? NSOnState : NSOffState)];
    
    /* Update the title of this menu item by firing the current timer */
    
    [MCTimer fire];
}

/* actionShowDay - actions to take when the show day menu item is clicked */

- (void)actionShowDay: (id)sender
{
    /* Toggle the setting for whether the day should be shown in the menubar */
    
    showDay = !showDay;

    /* Update the user's preferences */
    
    [[NSUserDefaults standardUserDefaults] setBool: showDay
                                            forKey: gPrefShowDay];

    /*
        Show a checkmark before this menu item if the date should be
        shown in the menubar:
        https://stackoverflow.com/questions/2176639/how-to-add-a-check-mark-to-an-nsmenuitem
     */
    
    [MCMenuItemShowDayInMenuBar setState: (showDay ? NSOnState : NSOffState)];
    
    /* Update the title of this menu item by firing the current timer */
    
    [MCTimer fire];
}

/* actionShowTime - actions to take when the show year menu item is clicked */

-(void)actionShowYear:(id)sender
{
    /* Toggle the setting for whether the day should be shown in the menubar */
    
    showYear = !showYear;
    
    /* Update the user's preferences */
    
    [[NSUserDefaults standardUserDefaults] setBool: showYear
                                            forKey: gPrefShowYear];
    
    /*
     Show a checkmark before this menu item if the date should be
     shown in the menubar:
     https://stackoverflow.com/questions/2176639/how-to-add-a-check-mark-to-an-nsmenuitem
     */
    
    [MCMenuItemShowYearInMenuBar setState: (showYear ? NSOnState : NSOffState)];
    
    /* Update the title of this menu item by firing the current timer */
    
    [MCTimer fire];
}

/* actionShowTime - actions to take when the show time menu item is clicked */

- (void)actionShowTime: (id)sender
{
    /* Toggle the setting for whether the time should be shown in the menubar */
    
    showTime = !showTime;

    /* Update the user's preferences */
    
    [[NSUserDefaults standardUserDefaults] setBool: showTime
                                            forKey: gPrefShowTime];

    /*
        Show a checkmark before this menu item if the time should be
        shown in the menubar:
        https://stackoverflow.com/questions/2176639/how-to-add-a-check-mark-to-an-nsmenuitem
    */
    
    [MCMenuItemShowTimeInMenuBar setState: (showTime ? NSOnState : NSOffState)];
    
    /* Update the title of this menu item by firing the current timer */

    [MCTimer fire];
}

/* actionShowTime - actions to take when the launch at login menu item is clicked */

- (void) actionLaunchAtLogin:(id)sender
{
    /* Toggle the setting for whether we should launch at login */

    launchAtLogin = !launchAtLogin;
    
    /* Update the user's preferences */
    
    [[NSUserDefaults standardUserDefaults] setBool: launchAtLogin
                                            forKey: gPrefLaunchAtLogin];

    /*
        Show a checkmark before this menu item if we should launch at login:
        https://stackoverflow.com/questions/2176639/how-to-add-a-check-mark-to-an-nsmenuitem
     */
    
    [MCMenuItemLaunchAtLogin setState: (launchAtLogin ? NSOnState : NSOffState)];

    if (!SMLoginItemSetEnabled ((__bridge CFStringRef)gHelperAppBundle, launchAtLogin))
    {
        NSAlert *alert = [NSAlert alertWithMessageText: @"An error ocurred"
                                         defaultButton: @"OK"
                                       alternateButton: nil
                                           otherButton: nil
                             informativeTextWithFormat: (launchAtLogin ?
                                                         @"Couldn't add Helper App to launch at login items list." :
                                                         @"Couldn't remove Helper App from login items list." )];
        [alert runModal];
    }
}

/* updateStatusItemTitle - update the title of this menu item */

- (void)updateStatusItemTitle
{
    NSMutableString *dateStr = nil;
    NSMutableString *timeStr = nil;
    NSMutableString *dateFormatStr = nil;
    NSDate *currentDate = nil;
    NSDateComponents *components = nil;
    NSInteger hour;
    NSInteger minute;
    NSDateFormatter *dateFormatter;
    
    /* Update the Date */
    
    [self updateDate];
    
    /*
        If neither the date nor the time should be shown in the menubar,
        use an icon and return.
     */
    
    if (showDate == FALSE && showTime == FALSE)
    {
        [self.statusItem setImage: [NSImage imageNamed: gMenuImage]];
        [self.statusItem.image setTemplate: YES];
        [self.statusItem setTitle: nil];
        return;
    }

    /* The date and/or time should be displayed in the menubar */
    
    /* Turn off the image */
    
    [self.statusItem setImage: nil];

    /* Get the current date */
    
    currentDate = [NSDate date];

    /* Initialize the date string to a blank */
    
    dateStr = [NSMutableString stringWithString: @""];
    dateFormatStr = [NSMutableString stringWithString: @""];
    timeStr = [NSMutableString stringWithFormat: @""];
    
    /*
        If the date is to be shown, format it using a date formatter:
        http://iosdevelopertips.com/cocoa/date-formatters-examples-take-2.html
        http://www.alexcurylo.com/2009/01/28/nsdateformatter-formatting/
     */
    
    if (showDate)
    {
        /*
            Initialize the date formatter to the current locale:
            http://iosdevelopertips.com/cocoa/date-formatter-examples-take-4-setting-locale.html
         */
        
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocale: [NSLocale currentLocale]];
        
        /* If requested, add the day to the date format string */

        if (showDay)
        {
            [dateFormatStr appendString: @"EEE "];
        }

        /* If requested, format the date in short style */
        
        if (showDateShortStyle)
        {
            [dateFormatStr appendString: @"LL/MM"];
            if (showYear)
            {
                [dateFormatStr appendString: @"/yyyy"];
            }
        }
        else
        {
            [dateFormatStr appendString: @"MMM dd"];
            if (showYear)
            {
                [dateFormatStr appendString: @" yyyy"];
            }
        }
        
        [dateFormatter setDateFormat: dateFormatStr];
        [dateStr appendString: [dateFormatter stringFromDate: currentDate]];
        [dateStr appendString:@" "];
    }

    /* If the time is to be shown, display it */
    
    if (showTime)
    {
        /*
            Get the current time as hours and minutes:
            https://stackoverflow.com/questions/2927028/how-do-i-get-hour-and-minutes-from-nsdate#2927074
         */
            
        components = [[NSCalendar currentCalendar]
                       components: (NSCalendarUnitHour | NSCalendarUnitMinute)
                         fromDate: currentDate];
        hour = [components hour];
        minute = [components minute];
        
        /*
            Left pad the time:
            https://stackoverflow.com/questions/6548790/how-do-i-left-pad-an-nsstring-to-fit-it-in-a-fixed-width
         */
        
        [timeStr appendFormat: @"%2ld%c%02ld",
                                (long)hour,
                                (showColon ? ':' : ' '),
                                (long)minute];
        [dateStr appendFormat: @"%-5s", [timeStr UTF8String]];
        
        /* Toggle the colon */
        
        showColon = !showColon;
    }
    
    /* Update the menubar */
    
    [self.statusItem setTitle: dateStr];
}

/* updateDate - update the date string in the menu and the date in the datepicker */

- (void)updateDate
{
    NSDate *currentDate = nil;
    NSMutableString *dateStr = nil;
    NSDateFormatter *dateFormatter = nil;
    
    /* Get the current date */
    
    currentDate = [NSDate date];

    /* Initialize the string that will hold the date */
    
    dateStr = [NSMutableString stringWithString:@""];

    /* If the day is to be shown, get it using a date formatter */

    if (showDay)
    {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"EEE"];
        [dateStr appendString: [dateFormatter stringFromDate: currentDate]];
        [dateStr appendString: @" "];
    }

    [dateStr appendString:
     [NSDateFormatter localizedStringFromDate: currentDate
                                    dateStyle: (showDateShortStyle ?
                                                NSDateFormatterShortStyle :
                                                NSDateFormatterMediumStyle)
                                    timeStyle: NSDateFormatterNoStyle]];

    /*
     Set the first menu item to the current date:
     https://stackoverflow.com/questions/576265/convert-nsdate-to-nsstring#11005104
     https://developer.apple.com/documentation/foundation/nsdateformatter#//apple_ref/occ/clm/NSDateFormatter/localizedStringFromDate%3adateStyle%3atimeStyle%3a
     */

    [MCMenuItemDate setTitle: dateStr];
    
    /*
        Set the date to the current date and don't allow selection of any
        other date:
        https://stackoverflow.com/questions/36913762/how-to-disable-future-date-and-not-scrolling-datepicker-in-swift-2#36914335
     */

    [MCDatePicker setDateValue: currentDate];
    [MCDatePicker setMinDate: currentDate];
    [MCDatePicker setMaxDate: currentDate];
}

@end
