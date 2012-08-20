//
//  DNShell.m
//  MailCount
//
//  Created by Paul van der Walt on 20/08/12.
//  Copyright (c) 2012 denknerd.org. All rights reserved.
//

#import "DNShell.h"

@implementation DNShell


+ (NSString *) doshellscript: (NSString *)cmd_launch_path args: (NSArray *) first_cmd_pt {
    
    NSTask *task = [NSTask new]; // Make a new task
    NSPipe *pipe = [NSPipe pipe];
    
    [task setLaunchPath: cmd_launch_path]; // Tell which command we are running
    [task setArguments: [NSArray arrayWithObjects: first_cmd_pt, nil]];
    [task setArguments:first_cmd_pt];
    [task setStandardOutput: pipe];
    [task launch];
    
    NSData *data = [[pipe fileHandleForReading] readDataToEndOfFile];    
    NSString *string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    
    return string;
}


@end
