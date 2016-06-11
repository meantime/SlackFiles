//
//  Group.m
//  Slack Files
//
//  Created by Chris DeSalvo on 6/11/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

#import "Group.h"

@implementation Group

+ (NSString *)primaryKey
{
    return @"groupId";
}

+ (NSDictionary *)valuesFromNetworkResponse:(NSDictionary *)response
{
    NSDictionary        *base = [[self superclass] valuesFromNetworkResponse:response];
    NSMutableDictionary *values = [NSMutableDictionary dictionary];

    [values addEntriesFromDictionary:base];

    values[@"groupId"] = response[@"id"];
    values[@"name"] = response[@"name"];

    return [NSDictionary dictionaryWithDictionary:values];
}

@end
