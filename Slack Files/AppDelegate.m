//
//  AppDelegate.m
//  Slack Files
//
//  Created by Chris DeSalvo on 5/30/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

#import "AppDelegate.h"

#import "NSURL+QueryArgs.h"
#import "SlackAuth.h"

@interface AppDelegate ()

@property (weak)    IBOutlet    NSWindow    *window;
@property (strong)              SlackAuth   *auth;

@end

@implementation AppDelegate

- (void)applicationWillFinishLaunching:(NSNotification *)notification
{

}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.auth = [SlackAuth new];

    [self.auth run];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{

}

@end
