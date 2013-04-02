//
//  DNAppDelegate.m
//  MailCount
//
//  Created by Paul van der Walt on 19/08/12.
//  Copyright (c) 2012 denknerd.org. All rights reserved.
//

#import "DNShell.h"
#import "DNAppDelegate.h"

@implementation DNAppDelegate

@synthesize menu, statusItem;
@synthesize activity;
@synthesize pause;

static NSArray * chars;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{

    activity = 0;
    // this option is less favourable since the spacing is ugly.
//    chars    = [NSArray arrayWithObjects:@"|", @"/", @"-", @"\\", nil];
    
    // this defines a simple animation 
    chars    = [NSArray arrayWithObjects:@"[ ..]",@"[. .]",@"[.. ]",@"[...]", nil];
}

- (void) refreshMailCount {

    // do a tick
    activity = (activity + 1) % [chars count];

    NSString* pausepath = [PAUSEFILE stringByReplacingOccurrencesOfString:@"~" withString:NSHomeDirectory()];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:pausepath];

    [self.pause setState:fileExists?NSOnState:NSOffState];

    if (fileExists) {
        // we're paused, show that.
        [self.statusItem setTitle:[NSString stringWithFormat:@"%@ %@",@"m:",@"paused"]];

    } else {
        // not paused, do stuff.
        NSFileManager * fm = [NSFileManager new];
        
        NSString * maildirNew = NSHomeDirectory();
        maildirNew = [NSString stringWithFormat:@"%@/Maildir/Gmail/INBOX/new", maildirNew];
        NSString * maildirNewWork = NSHomeDirectory();
        maildirNewWork = [NSString stringWithFormat:@"%@/Maildir/INRIA/INBOX/new", maildirNewWork];
        
        NSError* error = nil;
        NSArray * files = [fm contentsOfDirectoryAtPath:maildirNew error:&error];
        NSArray * filesWork = [fm contentsOfDirectoryAtPath:maildirNewWork error:&error];
        
        // get a list of running processes
        NSString* procs = [DNShell doshellscript:@"/bin/ps"
                                            args:[NSArray arrayWithObject:@"aux"]];
        
        // lines
        NSArray* procarray = [procs componentsSeparatedByString:@"\n"];
        // filter
        NSPredicate* pred = [NSPredicate predicateWithFormat:@"SELF contains 'offlineimap'"];
        // if the count of this array is 1, offlineimap is running, so we can set an activity indicator
        procarray = [procarray filteredArrayUsingPredicate:pred];
        
        if (!error) {
            if ([procarray count] == 0) {
                [self.statusItem setTitle:[NSString stringWithFormat:@"m: %ld, %ld", [files count], [filesWork count]]];
            } else {
                [self.statusItem setTitle:[NSString stringWithFormat:@"m: %ld, %ld %@",
                                           [files count], [filesWork count],
                                           [chars objectAtIndex:activity]]];
            }
        } else {
            [self.statusItem setTitle:[NSString stringWithFormat:@"%@ %@",@"m:",@"error"]];
        }
    }
}

- (IBAction) quitProgram: (id)sender {

    [NSApp performSelector:@selector(terminate:) withObject:nil afterDelay:0.0f];
    
}

- (IBAction)checkNow:(id)sender {
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/local/bin/offlineimap"];
    [task setArguments:[NSArray arrayWithObjects:@"-o", nil]];
    [task launch];

}

- (IBAction)pause:(id)sender {
    
    NSString* path = [PAUSEFILE stringByReplacingOccurrencesOfString:@"~" withString:NSHomeDirectory()];
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:path];
    
    if (fileExists) {
        // unpause.
        
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        
        [self.pause setState:NSOffState];
    } else {
        // pause now!
        
        NSTask *task = [[NSTask alloc] init];
        [task setLaunchPath:@"/usr/bin/touch"];
        [task setArguments:[NSArray arrayWithObjects:path, nil]];
        [task launch];
        
        [self.pause setState:NSOnState];
    }
    
}

- (void) raiseMailClient {
    NSString* path = [[NSBundle mainBundle] pathForResource:@"raise-client" ofType:@"scpt"];
    NSURL* url = [NSURL fileURLWithPath:path];
    NSDictionary* errors;
    NSAppleScript* appleScript = [[NSAppleScript alloc] initWithContentsOfURL:url error:&errors];
    NSDictionary* err;
    [appleScript executeAndReturnError:&err];
    if (err) {
        NSLog(@"errors = %@", err);
    }
    NSLog(@"path = %@", path);
    if (errors) {
        NSLog(@"errors2 = %@", errors);
        NSLog(@"apples = %@", appleScript);
    }
    
    
}

- (void)menuWillOpen {
    // status bar item was clicked.
    BOOL commandKeyDown = (([[NSApp currentEvent] modifierFlags] & NSCommandKeyMask)
                           == NSCommandKeyMask);
    
    if (!commandKeyDown) {
        [self raiseMailClient];
    } else {
        // just open menu
        [self.statusItem popUpStatusItemMenu:self.menu];
    }

}

- (void) awakeFromNib {
    self.statusItem = [[NSStatusBar systemStatusBar] 
                       statusItemWithLength:NSVariableStatusItemLength];

    [self.statusItem setTitle:@"MailCount"];
    [self.statusItem setHighlightMode:YES];

    self.statusItem.target = self;
    self.statusItem.action = @selector(menuWillOpen);

    NSTimer* timer;
    timer = [NSTimer timerWithTimeInterval:1.0f
                                    target:self 
                                  selector:@selector(refreshMailCount) 
                                  userInfo:nil 
                                   repeats:YES];
    
    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
    [runloop addTimer:timer forMode:NSRunLoopCommonModes];
    
}

@end
