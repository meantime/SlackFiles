//
//  File.m
//  Slack Files
//
//  Created by Chris DeSalvo on 6/4/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

#import "File.h"

#import "Team.h"

@implementation File

+ (NSDictionary *)valuesFromNetworkResponse:(NSDictionary *)response
{
    NSMutableDictionary *values = [NSMutableDictionary dictionary];

    values[@"fileId"] = response[@"id"];
    values[@"filename"] = response[@"name"];
    values[@"title"] = response[@"title"];
    values[@"mimeType"] = response[@"mimetype"];
    values[@"prettyType"] = response[@"pretty_type"];
    values[@"creatorUserId"] = response[@"user"];

    NSUInteger  number = [response[@"created"] unsignedIntegerValue];

    values[@"creationDate"] = [NSDate dateWithTimeIntervalSince1970:number];

    number = [response[@"size"] unsignedIntegerValue];
    values[@"filesize"] = [NSNumber numberWithUnsignedInteger:number];

    values[@"jsonBlob"] = [NSJSONSerialization dataWithJSONObject:response options:0 error:nil];

    return [NSDictionary dictionaryWithDictionary:values];
}

+ (NSString *)primaryKey
{
    return @"fileId";
}

+ (NSDate *)oldestTimestampForTeam:(Team *)team
{
    RLMRealm    *realm = [RLMRealm defaultRealm];
    RLMResults  *files = [File objectsInRealm:realm where:@"team = %@", team];
    NSDate      *oldestTimestamp = [files minOfProperty:@"creationDate"];

    if (nil == oldestTimestamp)
    {
        oldestTimestamp = [NSDate date];
    }

    return oldestTimestamp;
}

+ (NSDate *)oldesetTimestampInGapForTeam:(Team *)team
{
    RLMRealm    *realm = [RLMRealm defaultRealm];
    RLMResults  *files = [File objectsInRealm:realm where:@"team = %@ AND creationDate > %@", team, team.syncBoundary];
    NSDate      *oldestTimestamp = [files minOfProperty:@"creationDate"];

    if (nil == oldestTimestamp)
    {
        oldestTimestamp = [NSDate date];
    }

    return oldestTimestamp;
}

+ (NSDate *)newestTimestampForTeam:(Team *)team
{
    RLMRealm    *realm = [RLMRealm defaultRealm];
    RLMResults  *files = [File objectsInRealm:realm where:@"team = %@", team];

    NSDate      *newestTimestamp = [files maxOfProperty:@"creationDate"];

    if (nil == newestTimestamp)
    {
        newestTimestamp = [NSDate dateWithTimeIntervalSince1970:0.0];
    }

    return newestTimestamp;
}

@end
