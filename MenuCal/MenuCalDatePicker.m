/*
 MenuCal - MenuCalDatePicker.m
 
 History:
 
 v. 1.0.0 (11/03/2018) - Initial version
 
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

#import "MenuCalDatePicker.h"

@implementation MenuCalDatePicker

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

- (BOOL) acceptsFirstMouse:(NSEvent *)event
{
    /*
        Enable the datepicker to recieve mouse clicks:
        https://exceptionshub.com/nsdatepicker-in-nsstatusbar-nssmenuitem-not-receiving-input.html
     */
    
    return TRUE;
}

@end
