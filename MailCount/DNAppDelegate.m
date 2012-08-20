//
//  DNAppDelegate.m
//  MailCount
//
//  Created by Paul van der Walt on 19/08/12.
//  Copyright (c) 2012 denknerd.org. All rights reserved.
//

#import "DNAppDelegate.h"

@implementation DNAppDelegate

@synthesize window = _window;
@synthesize menu, statusItem;



- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (void) refreshMailCount {
//    NSLog(@"refresh");
    NSFileManager * fm = [NSFileManager new];
    
    NSString * maildirNew = NSHomeDirectory();
    
    maildirNew = [NSString stringWithFormat:@"%@/Maildir/INBOX/new", maildirNew];
//    NSLog(@"%@", maildirNew);
    
    NSError* error = nil;
    
    NSArray * files = [fm contentsOfDirectoryAtPath:maildirNew error:&error];
    
    if (!error) {
        [self.statusItem setTitle:[NSString stringWithFormat:@"m: %d", [files count]]];
    }
}

- (void) quitProgram {
//    NSLog(@"quit");
    
    [NSApp performSelector:@selector(terminate:) withObject:nil afterDelay:0.0f];
    
}

- (void) awakeFromNib {
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setMenu:self.menu];
    [self.statusItem setTitle:@"Mail"];
    [self.statusItem setHighlightMode:YES];
            
    [self.menu removeAllItems];
    [self.menu addItemWithTitle:@"Quit" action:@selector(quitProgram) keyEquivalent:@"?"];
    
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
