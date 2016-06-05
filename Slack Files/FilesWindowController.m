//
//  FilesWindowController.m
//  Slack Files
//
//  Created by Chris DeSalvo on 6/4/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

#import "FilesWindowController.h"

#import "File.h"
#import "SlackAPI.h"
#import "Team.h"

NS_ASSUME_NONNULL_BEGIN

NSString * const FilesWindowWillCloseNotification = @"FilesWindowWillCloseNotification";

@interface FilesWindowController () <NSWindowDelegate>

@property (readwrite)   Team                *team;
@property               SlackAPI            *api;
@property               NSUInteger          highestPage;
@property               NSUInteger          numPages;
@property               BOOL                fetchInProgress;

@end

@implementation FilesWindowController

+ (instancetype)windowControllerForTeam:(Team *)team
{
    FilesWindowController   *result = [[FilesWindowController alloc] initWithWindowNibName:@"FilesWindowController"];

    result.team = team;
    result.api = [[SlackAPI alloc] initWithTeam:team];

    return result;
}

- (void)windowDidLoad
{
    [super windowDidLoad];

    self.window.delegate = self;
    [self.window setTitle:self.team.teamName];

    [self.api callEndpoint:SlackEndpoints.teamInfo withArguments:nil completion:^(NSDictionary * _Nullable result, NSError * _Nullable error) {

        NSString    *iconURL = [Team bestImageURLFromTeamInfo:result];
        NSURL       *url = [NSURL URLWithString:iconURL];
        NSData      *iconData = [NSData dataWithContentsOfURL:url];
        NSImage     *icon = [[NSImage alloc] initWithData:iconData];

        self.window.representedURL = url;

        NSButton    *button = [self.window standardWindowButton:NSWindowDocumentIconButton];

        button.image = icon;
    }];

    [self fetchNextPage];
}

- (void)fetchNextPage
{
    if ((self.highestPage == self.numPages) && (YES == self.fetchInProgress))
    {
        self.fetchInProgress = NO;
        [self.team updateLastSyncDate];

        return;
    }

    self.fetchInProgress = YES;

    NSMutableDictionary *args = [NSMutableDictionary dictionary];

    //  Configure time range we're searching over
    NSTimeInterval      ts = [self.team.lastSyncDate timeIntervalSince1970];

    if (ts < 0)
    {
        ts = 0;
    }

    args[@"ts_from"] = [NSString stringWithFormat:@"%.0f", ts];

    //  Select the next page number of results, if any
    if (self.numPages > 0)
    {
        if (self.highestPage < self.numPages)
        {
            NSUInteger      page = self.highestPage + 1;

            args[@"page"] = [NSString stringWithFormat:@"%ld", page];
        }
    }

    [self.api callEndpoint:SlackEndpoints.filesList withArguments:args completion:^(NSDictionary * _Nullable result, NSError * _Nullable error) {

        NSDictionary    *paging = result[@"paging"];
        NSUInteger      number = [paging[@"pages"] unsignedIntegerValue];

        if (number > self.numPages)
        {
            self.numPages = number;
        }
        else if (number == 0)
        {
            //  The MAX is because if there are no files found the Slack API says that it is returning
            //  page 1 of 0.
            self.numPages = 1;
        }

        number = [paging[@"page"] unsignedIntegerValue];

        if (number > self.highestPage)
        {
            self.highestPage = number;
        }

        NSLog(@"[%@] page %ld of %ld", self.team.teamName, self.highestPage, self.numPages);
        [self processFileList:result[@"files"]];

        dispatch_async(dispatch_get_main_queue(), ^{

            [self fetchNextPage];
        });
    }];
}

- (void)processFileList:(NSArray *)files
{
    if (files.count < 1)
    {
        return;
    }

    RLMRealm    *realm = [RLMRealm defaultRealm];

    [realm transactionWithBlock:^{

        for (NSDictionary *f in files)
        {
            File    *file = [File objectInRealm:realm forPrimaryKey:f[@"id"]];

            if (nil == file)
            {
                NSDictionary    *values = [File valuesFromNetworkResponse:f];

                file = [File createInRealm:realm withValue:values];
                file.team = self.team;
            }
        }
    }];
}

#pragma mark - <NSWindowDelegate>

- (BOOL)windowShouldClose:(id)sender
{
    [self.api suspend];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:FilesWindowWillCloseNotification object:self.team.teamId];
    
    return YES;
}

- (BOOL)window:(NSWindow *)window shouldPopUpDocumentPathMenu: (NSMenu *)menu
{
    return NO;
}

- (BOOL)window:(NSWindow *)window shouldDragDocumentWithEvent:(NSEvent *)event from:(NSPoint)dragImageLocation withPasteboard:(NSPasteboard *)pasteboard
{
    return NO;
}

@end

NS_ASSUME_NONNULL_END
