/*
 MenuCal - AppDelegate.h
 
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

#import <Cocoa/Cocoa.h>
#import "MenuCalDatePicker.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    IBOutlet NSMenu *MCMenu;
    IBOutlet NSMenuItem *MCMenuItemDatePicker;
    IBOutlet NSMenuItem *MCMenuItemQuit;
    IBOutlet NSMenuItem *MCMenuItemDate;
    IBOutlet NSMenuItem *MCMenuItemShowDateInMenuBar;
    IBOutlet NSMenuItem *MCMenuItemShowDateShortStyleInMenuBar;
    IBOutlet NSMenuItem *MCMenuItemShowDayInMenuBar;
    IBOutlet NSMenuItem *MCMenuItemShowTimeInMenuBar;
    IBOutlet MenuCalDatePicker *MCDatePicker;
    NSTimer *MCTimer;
    BOOL showDate;
    BOOL showDateShortStyle;
    BOOL showDay;
    BOOL showTime;
    BOOL showColon;
}

- (void) actionTimer;
- (void) actionShowDate: (id)sender;
- (void) actionShowDateShortStyle: (id)sender;
- (void) actionShowDay: (id)sender;
- (void) actionShowTime: (id)sender;
- (void) updateStatusItemTitle;
- (void) updateDate;

@end

