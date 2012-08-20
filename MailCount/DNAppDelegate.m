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
    
    NSFileManager * fm = [NSFileManager new];
    
    NSString * maildirNew = NSHomeDirectory();
    maildirNew = [NSString stringWithFormat:@"%@/Maildir/INBOX/new", maildirNew];
    
    NSError* error = nil;
    NSArray * files = [fm contentsOfDirectoryAtPath:maildirNew error:&error];
    
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
            [self.statusItem setTitle:[NSString stringWithFormat:@"m: %d", [files count]]];
        } else {
            [self.statusItem setTitle:[NSString stringWithFormat:@"m: %d %@", 
                                       [files count], 
                                       [chars objectAtIndex:activity]]];
        }
    } else {
        [self.statusItem setTitle:@"m: error"];
    }
    
}

- (void) quitProgram {

    [NSApp performSelector:@selector(terminate:) withObject:nil afterDelay:0.0f];
    
}

- (void) awakeFromNib {
    self.statusItem = [[NSStatusBar systemStatusBar] 
                       statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setMenu:self.menu];
    [self.statusItem setTitle:@"MailCount"];
    [self.statusItem setHighlightMode:YES];
            
    [self.menu removeAllItems];
    [self.menu addItemWithTitle:@"Quit" action:@selector(quitProgram) keyEquivalent:@"q"];
    
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
