/*
 MenuCalLaunchAtLoginHelper - AppDelegate.m
 
 History:
 
 v. 1.0.0 (11/12/2018) - Initial version
 
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

/* Constants */

NSString *gAppBundle = @"org.calalum.ranga.MenuCal";
NSString *gAppName = @"MenuCal";
NSString *gMsgTerminate = @"Terminate";

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    BOOL alreadyRunning = NO;
    BOOL isActive = NO;
    NSArray *running = nil;
    NSString *path = nil;
    NSString *newPath = nil;
    NSMutableArray *pathComponents = nil;
    
    /*
        From:
        https://blog.timschroeder.net/2012/07/03/the-launch-at-login-sandbox-project/
        https://blog.timschroeder.net/2014/01/25/detecting-launch-at-login-revisited/
     
        See also:
        http://martiancraft.com/blog/2015/01/login-items/
        https://stackoverflow.com/questions/30587446/smloginitemsetenabled-start-at-login-with-app-sandboxed-xcode-6-3-illustrat     
     */
    
    // Check if main app is already running; if yes, do nothing and terminate helper app

    running = [[NSWorkspace sharedWorkspace] runningApplications];
    for (NSRunningApplication *app in running)
    {
        if ([[app bundleIdentifier] isEqualToString: gAppBundle])
        {
            alreadyRunning = YES;
            isActive = [app isActive];
            break;
        }
    }
    
    if (!alreadyRunning || !isActive)
    {
        path = [[NSBundle mainBundle] bundlePath];
        pathComponents = [NSMutableArray arrayWithArray: [path pathComponents]];
        [pathComponents removeLastObject];
        [pathComponents removeLastObject];
        [pathComponents removeLastObject];
        [pathComponents addObject: @"MacOS"];
        [pathComponents addObject: gAppName];
        newPath = [NSString pathWithComponents: pathComponents];
        [[NSWorkspace sharedWorkspace] launchApplication: newPath];
        
        [[NSDistributedNotificationCenter defaultCenter] addObserver: self
                                                            selector: @selector(actionTerminate)
                                                                name: gMsgTerminate
                                                              object: gAppBundle];
    }
    else
    {
        sleep (15);
        
        [NSApp terminate: nil];

    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    // Insert code here to tear down your application
}

- (void)actionTerminate
{
    [NSApp terminate: nil];
}

@end