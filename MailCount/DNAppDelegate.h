//
//  DNAppDelegate.h
//  MailCount
//
//  Created by Paul van der Walt on 19/08/12.
//  Copyright (c) 2012 denknerd.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DNAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (nonatomic, retain) NSStatusItem* statusItem;

@property (nonatomic, retain) IBOutlet NSMenu* menu;



@end
