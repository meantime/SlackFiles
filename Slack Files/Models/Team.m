//
//  Team.m
//  Slack Files
//
//  Created by Chris DeSalvo on 6/3/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

#import "Team.h"

#import "File.h"

@implementation Team

+ (NSString *)primaryKey
{
    return @"teamId";
}

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        self.syncBoundary = [NSDate date];
    }

    return self;
}

- (void)updateWithAuthResponse:(NSDictionary *)response
{
    if ([response[@"ok"] boolValue])
    {
        self.apiToken = response[@"access_token"];
        self.teamId = response[@"team_id"];
        self.teamName = response[@"team_name"];
        self.userId = response[@"user_id"];
    }
}

- (void)updateSyncBoundaryToDate:(NSDate *)date
{
    RLMRealm    *realm = [RLMRealm defaultRealm];

    [realm transactionWithBlock:^{

        self.syncBoundary = date;
    }];
}

+ (NSString *)bestImageURLFromTeamInfo:(NSDictionary *)info
{
    NSDictionary    *team = info[@"team"];
    NSDictionary    *icons = team[@"icon"];

#define TryIconNamed(x) { if (IsStringWithContents(icons[(x)])) return icons[(x)]; }

    TryIconNamed(@"image_original");
    TryIconNamed(@"image_230");
    TryIconNamed(@"image_132");
    TryIconNamed(@"image_102");
    TryIconNamed(@"image_88");
    TryIconNamed(@"image_68");
    TryIconNamed(@"image_44");
    TryIconNamed(@"image_34");

#undef TryIconNamed

    return @"";
}

@end
