//
//  Channel.m
//  Slack Files
//
//  Created by Chris DeSalvo on 6/11/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

#import "Channel.h"

@implementation Channel

+ (NSString *)primaryKey
{
    return @"channelId";
}

+ (NSDictionary *)valuesFromNetworkResponse:(NSDictionary *)response
{
    NSDictionary        *base = [[self superclass] valuesFromNetworkResponse:response];
    NSMutableDictionary *values = [NSMutableDictionary dictionary];

    [values addEntriesFromDictionary:base];

    values[@"channelId"] = response[@"id"];
    values[@"name"] = response[@"name"];

    NSUInteger  number;

    number = [response[@"is_archived"] unsignedIntegerValue];
    values[@"archived"] = [NSNumber numberWithBool:number ? YES : NO];

    return [NSDictionary dictionaryWithDictionary:values];
}

@end
