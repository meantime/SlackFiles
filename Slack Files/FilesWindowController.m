//
//  FilesWindowController.m
//  Slack Files
//
//  Created by Chris DeSalvo on 6/4/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

#import "FilesWindowController.h"

#import "File.h"
#import "FilesCollectionViewController.h"
#import "SlackAPI.h"
#import "Team.h"

NS_ASSUME_NONNULL_BEGIN

NSString * const FilesWindowWillCloseNotification = @"FilesWindowWillCloseNotification";

NS_ENUM(NSUInteger, FetchState)
{
    FetchStateNone,
    FetchStateOldMessages,
    FetchStateGapMessages,
    FetchStateNewMessages,
    FetchStateSyncComplete
};

@interface FilesWindowController () <NSWindowDelegate>

@property (readwrite)               Team                *team;
@property                           SlackAPI            *api;
@property                           NSUInteger          highestPage;
@property                           NSUInteger          numPages;
@property                           BOOL                fetchInProgress;
@property                           enum FetchState     fetchState;
@property (nullable)                NSDate              *fetchFromDate;
@property (nullable)                NSDate              *fetchToDate;
@property (weak)        IBOutlet    id<SyncUIDelegate>  syncUIDelegate;
@property                           NSUInteger          totalNewFileCount;
@property                           NSUInteger          totalFiles;

@property               FilesCollectionViewController *viewController;

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

    [self switchToViewController:[FilesCollectionViewController viewControllerForTeam:self.team]];
    [self.contentViewController loadView];

    [self fetchNextPage];
}

- (void)fetchNextPage
{
    if (FetchStateNone == self.fetchState)
    {
        NSLog(@"Kicking off new sync with old message backfill");

        //  We're just starting off so we'll be backfilling old messages
        self.fetchState = FetchStateOldMessages;

        self.fetchFromDate = [NSDate dateWithTimeIntervalSince1970:0.0];
        self.fetchToDate = [File oldestTimestampForTeam:self.team];

        [self reportDateRange];
    }

    //  Figure out what to do after each phase of fetching completes
    if ((self.highestPage == self.numPages) && (YES == self.fetchInProgress))
    {
        self.highestPage = 0;
        self.numPages = 0;

        if (FetchStateOldMessages == self.fetchState)
        {
            NSLog(@"Transitioning to gap messages");
            self.fetchState = FetchStateGapMessages;

            self.fetchFromDate = self.team.syncBoundary;
            self.fetchToDate = [File oldesetTimestampInGapForTeam:self.team];

            [self reportDateRange];
        }
        else if (FetchStateGapMessages == self.fetchState)
        {
            NSLog(@"Transitioning to new messages");
            self.fetchState = FetchStateNewMessages;

            self.fetchFromDate = [File newestTimestampForTeam:self.team];
            self.fetchToDate = [NSDate date];

            [self reportDateRange];
        }
        else if (FetchStateNewMessages == self.fetchState)
        {
            NSLog(@"Sync complete");

            self.fetchState = FetchStateNone;
            self.fetchInProgress = NO;

            [self.team updateSyncBoundaryToDate:self.fetchToDate];

            self.fetchFromDate = nil;
            self.fetchToDate = nil;

            return;
        }
    }

    self.fetchInProgress = YES;

    NSMutableDictionary *args = [NSMutableDictionary dictionary];

    //  Configure time range we're searching over
    NSTimeInterval  tsFrom = [self.fetchFromDate timeIntervalSince1970];
    NSTimeInterval  tsTo = [self.fetchToDate timeIntervalSince1970];

    args[@"ts_from"] = [NSString stringWithFormat:@"%.0f", tsFrom];
    args[@"ts_to"] = [NSString stringWithFormat:@"%.0f", tsTo];

    //  Select the next page number of results, if any
    if (self.numPages > 0)
    {
        if (self.highestPage < self.numPages)
        {
            NSUInteger      page = self.highestPage + 1;

            args[@"page"] = [NSString stringWithFormat:@"%ld", page];
        }
    }

    args[@"count"] = @"200";

    [self.api callEndpoint:SlackEndpoints.filesList withArguments:args completion:^(NSDictionary * _Nullable result, NSError * _Nullable error) {

        NSDictionary    *paging = result[@"paging"];
        NSUInteger      number = [paging[@"pages"] unsignedIntegerValue];

        if (YES == [result[@"ok"] boolValue])
        {
            //  If there are no files found the Slack API says that it is returning page 1 of 0.
            number = MAX(number, 1);
            self.numPages = MAX(self.numPages, number);

            number = [paging[@"page"] unsignedIntegerValue];
            self.highestPage = MAX(self.highestPage, number);

            number = [paging[@"total"] unsignedIntegerValue];
            self.totalFiles = MAX(self.totalFiles, number);

            NSLog(@"[%@] page %ld of %ld", self.team.teamName, self.highestPage, self.numPages);
            [self processFileList:result[@"files"]];

            dispatch_async(dispatch_get_main_queue(), ^{

                [self fetchNextPage];
            });
        }
        else
        {
            if ([@"max_page_limit" isEqualToString:result[@"error"]])
            {
                self.fetchState = self.fetchState - 1;

                if (FetchStateNone == self.fetchState)
                {
                    self.fetchInProgress = NO;
                }

                self.highestPage = 0;
                self.numPages = 0;

                dispatch_async(dispatch_get_main_queue(), ^{

                    [self fetchNextPage];
                });
            }
        }
    }];
}

- (void)processFileList:(NSArray *)files
{
    NSLog(@"Processing %ld files", files.count);
    
    if (files.count < 1)
    {
        return;
    }

    RLMRealm    *realm = [RLMRealm defaultRealm];

    [realm transactionWithBlock:^{

        NSUInteger  newFileCount = 0;

        for (NSDictionary *f in files)
        {
            File    *file = [File objectInRealm:realm forPrimaryKey:f[@"id"]];

            if (nil == file)
            {
                NSDictionary    *values = [File valuesFromNetworkResponse:f];

                file = [File createInRealm:realm withValue:values];
                file.team = self.team;

                newFileCount++;
            }
        }

        self.totalNewFileCount = self.totalNewFileCount + newFileCount;
        NSLog(@"Total files added: %ld out of %ld", self.totalNewFileCount, self.totalFiles);

        dispatch_async(dispatch_get_main_queue(), ^{

            [self.syncUIDelegate didFetchMoreFiles];
        });
    }];
}

- (void)close
{
    [self.api suspend];
    [super close];
}

- (void)reportDateRange
{
    NSDateFormatter *formatter = [NSDateFormatter new];

    formatter.dateStyle = NSDateFormatterMediumStyle;
    formatter.timeStyle = NSDateFormatterMediumStyle;
    formatter.timeZone = [NSTimeZone localTimeZone];

    NSString    *fromString = [formatter stringFromDate:self.fetchFromDate];
    NSString    *toString = [formatter stringFromDate:self.fetchToDate];

    NSLog(@"Fetching from %@ - %@", fromString, toString);
}

- (void)switchToViewController:(FilesCollectionViewController *)viewController
{
    NSView  *parent = [self.window contentView];

    [self.viewController.view removeFromSuperview];
    self.viewController = viewController;
    [parent addSubview:viewController.view];

    viewController.view.frame = parent.frame;

    self.syncUIDelegate = viewController;
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
