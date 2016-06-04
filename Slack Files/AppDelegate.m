//
//  AppDelegate.m
//  Slack Files
//
//  Created by Chris DeSalvo on 5/30/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

@import Realm;

#import "AppDelegate.h"

#import "KeychainAccess.h"
#import "NSURL+QueryArgs.h"
#import "SlackAuth.h"
#import "Team.h"

@interface AppDelegate ()

@property (weak)    IBOutlet    NSWindow    *window;
@property (strong)              SlackAuth   *auth;

@end

@implementation AppDelegate

- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
    [self configureRealm];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didAuthenticateTeam:)
                                                 name:SlackAuthDidAuthenticateTeamNotification
                                               object:nil];

    RLMResults<Team *>  *teams = [Team allObjects];

    if (0 == teams.count)
    {
        self.auth = [SlackAuth new];

        [self.auth run];
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{

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

    [realm transactionWithBlock:^{

        NSString    *teamId = args[@"team_id"];

        Team        *team = [Team objectForPrimaryKey:teamId];

        if (nil == team)
        {
            team = [Team new];
        }

        [team updateWithAuthResponse:args];

        [realm addOrUpdateObject:team];
    }];
}

@end
