//
//  IM.m
//  Slack Files
//
//  Created by Chris DeSalvo on 6/11/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

#import "IM.h"

@implementation IM

+ (NSString *)primaryKey
{
    return @"imId";
}

+ (NSDictionary *)valuesFromNetworkResponse:(NSDictionary *)response
{
    NSDictionary        *base = [[self superclass] valuesFromNetworkResponse:response];
    NSMutableDictionary *values = [NSMutableDictionary dictionary];

    [values addEntriesFromDictionary:base];

    values[@"imId"] = response[@"id"];
    values[@"name"] = response[@"name"];

    NSString    *otherUserId = response[@"user"];

    values[@"user"] = [User objectForPrimaryKey:otherUserId];

    NSUInteger  number;

    number = [response[@"is_user_deleted"] unsignedIntegerValue];
    values[@"deleted"] = [NSNumber numberWithBool:number ? YES : NO];

    return [NSDictionary dictionaryWithDictionary:values];
}

@end
