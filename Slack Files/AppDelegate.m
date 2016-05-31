//
//  AppDelegate.m
//  Slack Files
//
//  Created by Chris DeSalvo on 5/30/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

#import "AppDelegate.h"

#import "NSURL+QueryArgs.h"

@interface AppDelegate ()

@property (weak)    IBOutlet    NSWindow    *window;

@end

@implementation AppDelegate

- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self
                                                       andSelector:@selector(handleURLEvent:withReplyEvent:)
                                                     forEventClass:kInternetEventClass
                                                        andEventID:kAEGetURL];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{

}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{

}

- (void)handleURLEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{
    NSString    *urlString = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];

    if (IsStringWithContents(urlString))
    {
        NSURL   *url = [NSURL URLWithString:urlString];

        if ([[url scheme] isEqualToString:@"slackfiles"] && [[url host] isEqualToString:@"authendpoint"])
        {
            NSDictionary    *queryArgs = [url dictionaryFromQueryArgs];

            NSLog(@"%@", queryArgs);
        }
    }
}

@end
