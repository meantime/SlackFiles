//
//  AppDelegate.m
//  Slack Files
//
//  Created by Chris DeSalvo on 5/30/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

@import Realm;

#import "AppDelegate.h"

#import "File.h"
#import "FilesWindowController.h"
#import "ImageWindowController.h"
#import "KeychainAccess.h"
#import "NSURL+QueryArgs.h"
#import "PDFWindowController.h"
#import "SlackAuth.h"
#import "Team.h"
#import "TextWindowController.h"
#import "VideoWindowController.h"

NSString * const OpenFileWindowNotification = @"OpenFileWindowNotification";

@interface AppDelegate ()

@property SlackAuth       *auth;
@property NSMutableArray  *filesWindowControllers;
@property NSMutableArray  *otherWindowControllers;

@end

@implementation AppDelegate

- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
    [self configureRealm];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.filesWindowControllers = [NSMutableArray array];
    self.otherWindowControllers = [NSMutableArray array];

    NSNotificationCenter    *nc = [NSNotificationCenter defaultCenter];

    [nc addObserver:self
           selector:@selector(didAuthenticateTeam:)
               name:SlackAuthDidAuthenticateTeamNotification
             object:nil];

    [nc addObserver:self
           selector:@selector(fileWindowWillClose:)
               name:FilesWindowWillCloseNotification
             object:nil];

    [nc addObserver:self
           selector:@selector(openFileWindow:)
               name:OpenFileWindowNotification
             object:nil];

    RLMResults<Team *>  *teams = [Team allObjects];

    if (teams.count)
    {
        for (Team *team in teams)
        {
            [self openWindowForTeam:team];
        }
    }
    else
    {
        self.auth = [SlackAuth new];

        [self.auth run];
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FilesWindowWillCloseNotification object:nil];
}

- (void)configureRealm
{
    NSError *error = nil;
    NSData  *realmKey = [KeychainAccess readDataWithServiceName:@"Slack Files Realm key" error:&error];

    if (nil == realmKey)
    {
        NSMutableData   *key = [NSMutableData dataWithLength:64];

        SecRandomCopyBytes(kSecRandomDefault, key.length, (uint8_t *) key.mutableBytes);

        realmKey = [NSData dataWithData:key];

        [KeychainAccess writeData:realmKey withServiceName:@"Slack Files Realm key" error:&error];

        if (error)
        {
            NSAlert *alert = [NSAlert alertWithError:error];

            [alert runModal];
        }
    }

    RLMRealmConfiguration   *config = [RLMRealmConfiguration defaultConfiguration];

    config.encryptionKey = realmKey;
    [RLMRealmConfiguration setDefaultConfiguration:config];
}

- (void)didAuthenticateTeam:(NSNotification *)note
{
    NSDictionary    *args = (NSDictionary *) note.object;

    if (NO == [args[@"ok"] boolValue])
    {
        return;
    }

    RLMRealm     *realm = [RLMRealm defaultRealm];
    __block Team *team = nil;

    [realm transactionWithBlock:^{

        NSString    *teamId = args[@"team_id"];

        team = [Team objectForPrimaryKey:teamId];

        if (nil == team)
        {
            team = [Team new];
        }

        [team updateWithAuthResponse:args];

        [realm addOrUpdateObject:team];
    }];

    self.auth = nil;
    [self openWindowForTeam:team];
}

- (void)openWindowForTeam:(Team *)team
{
    for (FilesWindowController *wc in self.filesWindowControllers)
    {
        if ([team.teamId isEqualToString:wc.team.teamId])
        {
            [wc.window makeKeyAndOrderFront:nil];
            return;
        }
    }

    FilesWindowController   *w = [FilesWindowController windowControllerForTeam:team];

    [self.filesWindowControllers addObject:w];
    [w window];
}

- (void)fileWindowWillClose:(NSNotification *)note
{
    NSString    *teamId = (NSString *) note.object;

    for (FilesWindowController *wc in self.filesWindowControllers)
    {
        if ([teamId isEqualToString:wc.team.teamId])
        {
            [self removeDataForTeam:wc.team];
            [self.filesWindowControllers removeObject:wc];

            return;
        }
    }
}

- (IBAction)addNewTeam:(id)sender
{
    if (self.auth)
    {
        return;
    }

    self.auth = [SlackAuth new];
    [self.auth run];
}

- (IBAction)removeAllData:(id)sender
{
    for (FilesWindowController *wc in self.filesWindowControllers)
    {
        [wc close];
        [self.filesWindowControllers removeObject:wc];
    }

    RLMRealm    *realm = [RLMRealm defaultRealm];

    [realm transactionWithBlock:^{

        [realm deleteAllObjects];
    }];
}

- (IBAction)logRealmKey:(id)sender
{
    NSData  *realmKey = [KeychainAccess readDataWithServiceName:@"Slack Files Realm key" error:nil];

    if (nil == realmKey)
    {
        NSLog(@"No Realm encryption key stored");
    }
    else
    {
        NSString        *hex = realmKey.description;
        NSMutableCharacterSet  *c = [NSMutableCharacterSet whitespaceAndNewlineCharacterSet];

        [c addCharactersInString:@"<>"];

        NSArray *hexBits = [hex componentsSeparatedByCharactersInSet:c];

        hex = [hexBits componentsJoinedByString:@""];

        NSLog(@"Realm key: %@", hex);
    }
}

- (void)removeDataForTeam:(Team *)team
{
    RLMRealm    *realm = [RLMRealm defaultRealm];

    [realm transactionWithBlock:^{

        [realm deleteObject:team];
    }];
}

- (void)openFileWindow:(NSNotification *)note
{
    if (NO == [note.object isKindOfClass:[File class]])
    {
        return;
    }

    File        *file = (File *) note.object;
    NSString    *mimeType = file.mimeType;

    NSLog(@"Request to open file of type: %@", mimeType);

    if ([mimeType hasPrefix:@"video/"])
    {
        VideoWindowController   *window = [VideoWindowController windowControllerForFile:file];

        [window window];
        [window.window makeKeyAndOrderFront:self];

        [self.otherWindowControllers addObject:window];
    }
    else if ([mimeType hasPrefix:@"image/"])
    {
        ImageWindowController   *window = [ImageWindowController windowControllerForFile:file];

        [window window];
        [window.window makeKeyAndOrderFront:self];

        [self.otherWindowControllers addObject:window];
    }
    else if ([mimeType hasPrefix:@"audio/"])
    {
        VideoWindowController   *window = [VideoWindowController windowControllerForFile:file];

        [window window];
        [window.window makeKeyAndOrderFront:self];

        [self.otherWindowControllers addObject:window];
    }
    else if ([file.prettyType isEqualToString:@"Post"])
    {
        //  This must come before other things that are text/*
    }
    else if ([mimeType isEqualToString:@"text/html"])
    {

    }
    else if ([mimeType hasPrefix:@"text/"])
    {
        TextWindowController    *window = [TextWindowController windowControllerForFile:file];

        [window window];
        [window.window makeKeyAndOrderFront:self];

        [self.otherWindowControllers addObject:window];
    }
    else if ([mimeType isEqualToString:@"text/html"])
    {

    }
    else if ([mimeType isEqualToString:@"application/pdf"])
    {
        PDFWindowController *window = [PDFWindowController windowControllerForFile:file];

        [window window];
        [window.window makeKeyAndOrderFront:self];

        [self.otherWindowControllers addObject:window];
    }
}

- (void)windowWillClose:(NSWindowController *)windowController
{
    [self.otherWindowControllers removeObject:windowController];
}

@end
