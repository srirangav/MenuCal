/*
    MenuCal - AppDelegate.m
 
    History:
 
    v. 1.0.0 (11/05/2018) - Initial version
    v. 1.0.1 (11/07/2018) - Save user preferences
    v. 1.0.2 (11/12/2018) - Add support for launching at login time
    v. 1.0.3 (11/18/2018) - Add support for timezones
    v. 1.0.4 (12/05/2018) - Add support for full month names
    v. 1.0.5 (01/25/2019) - Add support for app groups / shared preferences
 
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
#import "Prefs.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (strong, nonatomic) NSStatusItem *statusItem;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:
    (NSNotification *)aNotification
{
    NSArray *apps = nil;
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

    /*
        Create a preference group to share preferences with the login
        helper app:
        https://stackoverflow.com/questions/14014417/reading-nsuserdefaults-from-helper-app-in-the-sandbox
     */
    
    MCDefaults = [[NSUserDefaults alloc] initWithSuiteName: gAppGroup];
    
    /* Get the user's preferences for displaying the date, day, and time */

    showDate = [MCDefaults boolForKey: gPrefShowDate];
    showDateShortStyle = [MCDefaults boolForKey: gPrefShowDateShortStyle];
    showFullMonth = [MCDefaults boolForKey: gPrefShowFullMonth];
    showDay = [MCDefaults boolForKey: gPrefShowDay];
    showYear = [MCDefaults boolForKey: gPrefShowYear];
    showTime = [MCDefaults boolForKey: gPrefShowTime];
    showTimeZone = [MCDefaults boolForKey: gPrefShowTimeZone];
    launchAtLogin = [MCDefaults boolForKey: gPrefLaunchAtLogin];
    
    /*
        Configure showColon to true so that the colon is initially seen when the
        time is displayed in the menu bar
     */
    
    showColon = TRUE;
    
    /* Set the actions for the menu items */
    
    [MCMenuItemShowDateInMenuBar setAction:
     @selector(actionShowDate:)];

    [MCMenuItemShowDateShortStyleInMenuBar setAction:
     @selector(actionShowDateShortStyle:)];

    [MCMenuItemShowFullMonthInMenuBar setAction:
     @selector(actionShowFullMonth:)];

    [MCMenuItemShowDayInMenuBar setAction:
     @selector(actionShowDay:)];

    [MCMenuItemShowYearInMenuBar setAction:
     @selector(actionShowYear:)];

    [MCMenuItemShowTimeInMenuBar setAction:
     @selector(actionShowTime:)];

    [MCMenuItemShowTimeZone setAction:
     @selector(actionShowTimeZone:)];
    
    [MCMenuItemLaunchAtLogin setAction:
     @selector(actionLaunchAtLogin:)];
    
    /*
        Set the state of (checkmark) of the menu items based on the user's
        preferences
     */
    
    [MCMenuItemShowDateInMenuBar setState:
     (showDate ? NSOnState : NSOffState)];
    
    [MCMenuItemShowDateShortStyleInMenuBar setState:
     (showDateShortStyle ? NSOnState : NSOffState)];

    [MCMenuItemShowFullMonthInMenuBar setState:
     (showFullMonth ? NSOnState : NSOffState)];

    [MCMenuItemShowDayInMenuBar setState:
     (showDay ? NSOnState : NSOffState)];
    
    [MCMenuItemShowYearInMenuBar setState:
     (showYear ? NSOnState : NSOffState)];
    
    [MCMenuItemShowTimeInMenuBar setState:
     (showTime ? NSOnState : NSOffState)];
    
    [MCMenuItemShowTimeZone setState:
     (showTimeZone ? NSOnState : NSOffState)];

    [MCMenuItemLaunchAtLogin setState:
     (launchAtLogin ? NSOnState : NSOffState)];
    
    /*
        Enable / disable the menu bar items:
        https://stackoverflow.com/questions/4524294/disabled-nsmenuitem#4683010
     
        Note: this works b/c the menu is marked as not auto-enable in MainMenu.xib

        Rules:
        1. "Show Date", "Show Time", "Launch At Login", and "Quit" should always
           be enabled.
        2. "With Day", "With Year", and "Short Style" should be enabled only if
           the user wants the date to be shown in the menu bar.
        3. "Full Date" should only be enabled if "Short Style" is disabled and
           the user wants the date to be shown in the menu bar.
        4. "With Timezone" should be enabled only if the user wants the time
           displayed in the menu bar.
        5. The static date should always be disabled.
     */
    
    [MCMenuItemShowDateInMenuBar setEnabled: TRUE];
    [MCMenuItemShowTimeInMenuBar setEnabled: TRUE];
    [MCMenuItemLaunchAtLogin setEnabled: TRUE];
    [MCMenuItemQuit setEnabled: TRUE];
    
    [MCMenuItemShowDayInMenuBar setEnabled: showDate];
    [MCMenuItemShowYearInMenuBar setEnabled: showDate];
    [MCMenuItemShowDateShortStyleInMenuBar setEnabled: showDate];

    [MCMenuItemShowFullMonthInMenuBar setEnabled:
     (showDate && !showDateShortStyle) ? TRUE : FALSE];

    [MCMenuItemShowTimeZone setEnabled: showTime];
    
    [MCMenuItemDate setEnabled: FALSE];

    /* Create a new datepicker in graphic mode without a border */
    
    MCDatePicker = [[MenuCalDatePicker alloc]
                    initWithFrame: NSMakeRect(0, 0, 140, 148)];
    [MCDatePicker setDatePickerStyle: NSClockAndCalendarDatePickerStyle];
    [MCDatePicker setBordered: FALSE];

    /*
        Make the datepicker the view for the menuitem:
        https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/MenuList/Articles/ViewsInMenuItems.html
    */

    [MCMenuItemDatePicker setView: MCDatePicker];

    /* Enable the update timer */
    
    [self actionTimer];

    /*
        Terminate the helper if it is running:
        https://blog.timschroeder.net/2014/01/25/detecting-launch-at-login-revisited/
     */

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

    /* Update the menu item and menu bar */
    
    [self updateDate];
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
    
    [MCDefaults setBool: showDate forKey: gPrefShowDate];
    
    /*
        Show a checkmark before this menu item if the date should be
        shown in the menubar:
        https://stackoverflow.com/questions/2176639/how-to-add-a-check-mark-to-an-nsmenuitem
     */
    
    [MCMenuItemShowDateInMenuBar setState: (showDate ? NSOnState : NSOffState)];

    /*
        Enable / disable the show day, show date in short style, and
        show year menu items based on whether the date is displayed
     */
    
    [MCMenuItemShowDayInMenuBar setEnabled: showDate];
    [MCMenuItemShowDateShortStyleInMenuBar setEnabled: showDate];
    [MCMenuItemShowYearInMenuBar setEnabled: showDate];
    
    /* Update the title of this menu item by firing the current timer */
    
    [MCTimer fire];
 }

/*
    actionShowDateShortStyle - actions to take when the show date in short
                               style menu item is clicked
 */

- (void)actionShowDateShortStyle:(id)sender
{
    /* Toggle the setting for whether the day should be shown in the menubar */
    
    showDateShortStyle = !showDateShortStyle;

    /* Update the user's preferences */
    
    [MCDefaults setBool: showDateShortStyle forKey: gPrefShowDateShortStyle];

    /*
        Show a checkmark before this menu item if the date should be
        shown in short style:
        https://stackoverflow.com/questions/2176639/how-to-add-a-check-mark-to-an-nsmenuitem
     */
    
    [MCMenuItemShowDateShortStyleInMenuBar setState:
     (showDateShortStyle ? NSOnState : NSOffState)];

    /*
        Disable / enable the "Full Month" menu item, depending on the
        user's choices for "Show Date" and "Short Style".
     */
    
    [MCMenuItemShowFullMonthInMenuBar setEnabled:
     (showDate && !showDateShortStyle) ? TRUE : FALSE];
    
    /* Update the title of this menu item by firing the current timer */
    
    [MCTimer fire];
}

/*
    actionShowFullMonth - actions to take when the show full month menu item
                          is clicked
 */

- (void)actionShowFullMonth:(id)sender
{
    /* Toggle the setting for whether the day should be shown in the menubar */
    
    showFullMonth = !showFullMonth;
    
    /* Update the user's preferences */
    
    [MCDefaults setBool: showFullMonth forKey: gPrefShowFullMonth];
    
    /*
        Show a checkmark before this menu item if the date should be
        shown in short style:
        https://stackoverflow.com/questions/2176639/how-to-add-a-check-mark-to-an-nsmenuitem
     */
    
    [MCMenuItemShowFullMonthInMenuBar setState:
     (showFullMonth ? NSOnState : NSOffState)];
    
    /* Update the title of this menu item by firing the current timer */
    
    [MCTimer fire];
}

/* actionShowDay - actions to take when the show day menu item is clicked */

- (void)actionShowDay: (id)sender
{
    /* Toggle the setting for whether the day should be shown in the menubar */
    
    showDay = !showDay;

    /* Update the user's preferences */
    
    [MCDefaults setBool: showDay forKey: gPrefShowDay];

    /*
        Show a checkmark before this menu item if the date should be
        shown in the menubar:
        https://stackoverflow.com/questions/2176639/how-to-add-a-check-mark-to-an-nsmenuitem
     */
    
    [MCMenuItemShowDayInMenuBar setState:
     (showDay ? NSOnState : NSOffState)];
    
    /* Update the title of this menu item by firing the current timer */
    
    [MCTimer fire];
}

/* actionShowYear - actions to take when the show year menu item is clicked */

-(void)actionShowYear:(id)sender
{
    /* Toggle the setting for whether the day should be shown in the menubar */
    
    showYear = !showYear;
    
    /* Update the user's preferences */
    
    [MCDefaults setBool: showYear forKey: gPrefShowYear];

    /*
     Show a checkmark before this menu item if the date should be
     shown in the menubar:
     https://stackoverflow.com/questions/2176639/how-to-add-a-check-mark-to-an-nsmenuitem
     */
    
    [MCMenuItemShowYearInMenuBar setState:
     (showYear ? NSOnState : NSOffState)];
    
    /* Update the title of this menu item by firing the current timer */
    
    [MCTimer fire];
}

/* actionShowTime - actions to take when the show time menu item is clicked */

- (void)actionShowTime: (id)sender
{
    /* Toggle the setting for whether the time should be shown in the menubar */
    
    showTime = !showTime;

    /* Update the user's preferences */
    
    [MCDefaults setBool: showTime forKey: gPrefShowTime];

    /*
        Show a checkmark before this menu item if the time should be
        shown in the menubar:
        https://stackoverflow.com/questions/2176639/how-to-add-a-check-mark-to-an-nsmenuitem
    */
    
    [MCMenuItemShowTimeInMenuBar setState: (showTime ? NSOnState : NSOffState)];
    
    /*
        Enable/disable the show timezone menu item based on whether
        the time should be shown in the menu bar
     */
    
    [MCMenuItemShowTimeZone setEnabled: showTime];
    
    /* Update the title of this menu item by firing the current timer */

    [MCTimer fire];
}

/*
    actionShowTimeZone - actions to take when the show timezone menu item
                         is clicked
 */

- (void)actionShowTimeZone:(id)sender
{
    /* Toggle the setting for whether the timezone should be shown */
    
    showTimeZone = !showTimeZone;
    
    /* Update the user's preferences */
    
    [MCDefaults setBool: showTimeZone forKey: gPrefShowTimeZone];

    /*
        Show a checkmark before this menu item if the time should be
        shown in the menubar:
        https://stackoverflow.com/questions/2176639/how-to-add-a-check-mark-to-an-nsmenuitem
     */
    
    [MCMenuItemShowTimeZone setState: (showTimeZone ? NSOnState : NSOffState)];
    
    /* Update the title of this menu item by firing the current timer */
    
    [MCTimer fire];
}

/*
    actionLaunchAtLogin - actions to take when the launch at login menu item
                          is clicked
 */

- (void) actionLaunchAtLogin:(id)sender
{
    /* Toggle the setting for whether we should launch at login */

    launchAtLogin = !launchAtLogin;
    
    /* Update the user's preferences */
    
    [MCDefaults setBool: launchAtLogin forKey: gPrefLaunchAtLogin];

    /*
        Show a checkmark before this menu item if we should launch at login:
        https://stackoverflow.com/questions/2176639/how-to-add-a-check-mark-to-an-nsmenuitem
     */
    
    [MCMenuItemLaunchAtLogin setState:
     (launchAtLogin ? NSOnState : NSOffState)];

    if (!SMLoginItemSetEnabled ((__bridge CFStringRef)gHelperAppBundle,
                                launchAtLogin))
    {
        NSAlert *alert =
            [NSAlert alertWithMessageText: @"An error ocurred"
                            defaultButton: @"OK"
                          alternateButton: nil
                              otherButton: nil
                informativeTextWithFormat: (launchAtLogin ?
                                            @"Can't add helper to login items." :
                                            @"Can't remove helper from login items." )];
        [alert runModal];
    }
}

/* updateStatusItemTitle - update the title of this menu item */

- (void)updateStatusItemTitle
{
    NSMutableString *dateFormatStr = nil;
    NSString *currentDateFormat = nil;
    NSDate *currentDate = nil;
    NSDateFormatter *dateFormatter;
    NSLocale *currentLoc = nil;
    BOOL timeIn24HrFormat = FALSE;
    
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

    /*
        The date and/or time should be displayed in the menubar, so turn
        off the icon.
     */
    
    [self.statusItem setImage: nil];

    /* Get the current date and locale */
    
    currentDate = [NSDate date];
    currentLoc = [NSLocale currentLocale];
    
    /*
        Initialize the date string, the date format string, and the
        time string to blank strings
     */
    
    dateFormatStr = [NSMutableString stringWithString: @""];
    
    /*
        Initialize the date formatter to the current locale:
        http://iosdevelopertips.com/cocoa/date-formatter-examples-take-4-setting-locale.html
     */
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale: currentLoc];

    /*
        If the date is to be shown, format it using a date formatter:
        http://iosdevelopertips.com/cocoa/date-formatters-examples-take-2.html
        http://www.alexcurylo.com/2009/01/28/nsdateformatter-formatting/
        https://www.codingexplorer.com/swiftly-getting-human-readable-date-nsdateformatter/
     */
    
    if (showDate)
    {
        /* If requested, add the day to the date format string */

        if (showDay)
        {
            [dateFormatStr appendString: @"EEE "];
        }

        /*
            If requested, format the date in short style.  Otherwise format
            the date with the month and the day (w/o 0 padding).  If the
            full month is requested, then format accordingly.
        */
        
        if (showDateShortStyle)
        {
            [dateFormatStr appendString: @"LL/MM"];
        }
        else
        {
            [dateFormatStr appendString:
             (showFullMonth ? @"MMMM d" : @"MMM d")];
        }
        
        /*
            Add the year, if requested (with a slash, if the date is being
            displayed in short form)
         */

        if (showYear)
        {
            [dateFormatStr appendFormat: @"%cyyyy",
             (showDateShortStyle ? '/' : ' ')];
        }
    }

    /* If the time is to be shown, add it to the date format string */
    
    if (showTime)
    {
        /*
            If the date is being shown, add a space between the date
            and the time
         */
        
        if (showDate)
        {
            [dateFormatStr appendString: @" "];
        }

        /*
            If the system displays time in 24hr format, make sure it
            is reflected in the date formatter:
            https://stackoverflow.com/questions/23114926/get-time-format-am-pm-or-24hrs-from-current-calendar-locale
         */
        
        currentDateFormat =
            [NSDateFormatter dateFormatFromTemplate: @"jm"
                                            options: 0
                                             locale: currentLoc];
        timeIn24HrFormat =
            ([currentDateFormat rangeOfString:@"H"].location != NSNotFound ||
             [currentDateFormat rangeOfString:@"k"].location != NSNotFound);
        
        [dateFormatStr appendString: (timeIn24HrFormat ? @"HH" : @"hh")];
        
        /* blink the colon */
        
        [dateFormatStr appendFormat: @"%cmm", (showColon ? ':' : ' ')];
        showColon = !showColon;
        
        /* Add the timezone, if requested */
        
        if (showTimeZone)
        {
            [dateFormatStr appendString: @" z"];
        }
    }

    /* Set the date formatter's format string as formatted above */
    
    [dateFormatter setDateFormat: dateFormatStr];

    /* Update the menubar */
    
    [self.statusItem setTitle: [dateFormatter stringFromDate: currentDate]];
}

/*
    updateDate - update the date string in the menu and the date in
                 the datepicker
 */

- (void)updateDate
{
    NSDate *currentDate = nil;
    NSMutableString *dateStr = nil;
    NSDateFormatter *dateFormatter = nil;
    
    /* Get the current date */
    
    currentDate = [NSDate date];

    /* Initialize the string that will hold the date */
    
    dateStr = [NSMutableString stringWithString: @""];

    /* If the day is to be shown, get it using a date formatter */

    if (showDay)
    {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"EEE"];
        [dateStr appendString: [dateFormatter stringFromDate: currentDate]];
        [dateStr appendString: @" "];
    }

    /* TODO: Update this for showFullDate */
    
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
