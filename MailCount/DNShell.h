//
//  DNShell.h
//  MailCount
//
//  Created by Paul van der Walt on 20/08/12.
//  Copyright (c) 2012 denknerd.org. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DNShell : NSObject

+ (NSString *) doshellscript: (NSString *)cmd_launch_path args: (NSArray *) first_cmd_pt;

@end
