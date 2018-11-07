/*
 MenuCal - AppDelegate.m
 
 History:
 
 v. 1.0.0 (11/05/2018) - Initial version
 
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

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (strong, nonatomic) NSStatusItem *statusItem;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:
    (NSNotification *)aNotification
{
    /*
        Create the status item and set its icon:
        http://preserve.mactech.com/articles/mactech/Vol.22/22.02/Menulet/index.html
     */
    
    self.statusItem = [[NSStatusBar systemStatusBar]
                       statusItemWithLength: NSVariableStatusItemLength];
    [self.statusItem setHighlightMode: YES];
    [self.statusItem setMenu: MCMenu];

    /*
        Configure the show date and time menu items to false initially, but
        configure showColon to true so that the colon is initially seen
     */
    
    showDate = FALSE;
    showDateShortStyle = FALSE;
    showDay = FALSE;
    showTime = FALSE;
    showColon = TRUE;
    
    /* Set the actions for show date and show time menu items */
    
    [MCMenuItemShowDateInMenuBar setAction:@selector(actionShowDate:)];
    [MCMenuItemShowDateShortStyleInMenuBar setAction:@selector(actionShowDateShortStyle:)];
    [MCMenuItemShowDayInMenuBar setAction:@selector(actionShowDay:)];
    [MCMenuItemShowTimeInMenuBar setAction:@selector(actionShowTime:)];

    /*
        Enable the menu bar items (except for the date):
        https://stackoverflow.com/questions/4524294/disabled-nsmenuitem#4683010
     
        NOTE: the menu is marked as not auto-enable in MainMenu.xib
     */
    
    [MCMenuItemShowDateInMenuBar setEnabled:TRUE];
    [MCMenuItemShowDayInMenuBar setEnabled:TRUE];
    [MCMenuItemShowTimeInMenuBar setEnabled:TRUE];
    [MCMenuItemQuit setEnabled: TRUE];
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
    
    if (showTime) {
        duration = (showDate ? 1.5 : 2.0);
    }

    /* update the menu bar */
    
    [self updateStatusItemTitle];
    
    /* start a new timer */
    
    MCTimer = [NSTimer scheduledTimerWithTimeInterval: duration
                                               target: self
                                             selector: @selector(actionTimer)
                                             userInfo: nil
                                              repeats: NO];
}

/* actionShowDate - actions to take when the show date menu item is clicked */

- (void)actionShowDate: (id)sender
{
    /* toggle the setting for whether the date should be shown in the menubar */

    showDate = !showDate;
    
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
    
    /* update the title of this menu item by firing the current timer */
    
    [MCTimer fire];
 }

/*
    actionShowDate - actions to take when the show date in short style menu
                     item is clicked
 */

- (void)actionShowDateShortStyle:(id)sender
{
    /* toggle the setting for whether the day should be shown in the menubar */
    
    showDateShortStyle = !showDateShortStyle;

    /*
     Show a checkmark before this menu item if the date should be
     shown in short style:
     https://stackoverflow.com/questions/2176639/how-to-add-a-check-mark-to-an-nsmenuitem
     */
    
    [MCMenuItemShowDateShortStyleInMenuBar setState:
     (showDateShortStyle ? NSOnState : NSOffState)];
    
    /* update the title of this menu item by firing the current timer */
    
    [MCTimer fire];
}

/* actionShowDay - actions to take when the show day menu item is clicked */

- (void)actionShowDay: (id)sender
{
    /* toggle the setting for whether the day should be shown in the menubar */
    
    showDay = !showDay;
    
    /*
     Show a checkmark before this menu item if the date should be
     shown in the menubar:
     https://stackoverflow.com/questions/2176639/how-to-add-a-check-mark-to-an-nsmenuitem
     */
    
    [MCMenuItemShowDayInMenuBar setState: (showDay ? NSOnState : NSOffState)];
    
    /* update the title of this menu item by firing the current timer */
    
    [MCTimer fire];
}

/* actionShowTime - actions to take when the show time menu item is clicked */

- (void)actionShowTime: (id)sender
{
    /* toggle the setting for whether the time should be shown in the menubar */
    
    showTime = !showTime;

    /*
        Show a checkmark before this menu item if the time should be
        shown in the menubar:
        https://stackoverflow.com/questions/2176639/how-to-add-a-check-mark-to-an-nsmenuitem
    */
    
    [MCMenuItemShowTimeInMenuBar setState: (showTime ? NSOnState : NSOffState)];
    
    /* update the title of this menu item by firing the current timer */

    [MCTimer fire];
}

/* updateStatusItemTitle - update the title of this menu item */

- (void)updateStatusItemTitle
{
    NSMutableString *dateStr = nil;
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
    
    if (showDate == FALSE && showTime == FALSE) {
        [self.statusItem setImage: [NSImage imageNamed: @"MenuCal.png"]];
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
    
    dateStr = [NSMutableString stringWithString:@""];

    /* If the date is to be shown, get it using a date formatter */
    
    if (showDate) {

        /* if the day is to be shown, get it using a date formatter */
        
        if (showDay) {
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
        [dateStr appendString:@" "];
    }

    /* If the time is to be shown, display it */
    
    if (showTime) {
        /*
            Get the current time as hours and minutes:
            https://stackoverflow.com/questions/2927028/how-do-i-get-hour-and-minutes-from-nsdate#2927074
         */
            
        components = [[NSCalendar currentCalendar]
                       components: (NSCalendarUnitHour | NSCalendarUnitMinute)
                         fromDate: currentDate];
        hour = [components hour];
        minute = [components minute];
            
        [dateStr appendFormat: @"%02ld%c%02ld",
                                (long)hour,
                                (showColon ? ':' : ' '),
                                (long)minute];

        /* Toggle the colon */
        
        showColon = !showColon;
    }
    
    /* update the menubar */
    
    [self.statusItem setTitle: dateStr];
}

/* updateDate - update the date string in the menu and the date in the datepicker */

- (void)updateDate
{
    NSDate *currentDate = nil;
    NSMutableString *dateStr = nil;
    NSDateFormatter *dateFormatter = nil;
    
    /* get the current date */
    
    currentDate = [NSDate date];

    /* initialize the string that will hold the date */
    
    dateStr = [NSMutableString stringWithString:@""];

    /* if the day is to be shown, get it using a date formatter */

    if (showDay) {
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
