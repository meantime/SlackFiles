//
//  File.m
//  Slack Files
//
//  Created by Chris DeSalvo on 6/4/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

#import "File.h"

@implementation File

+ (NSDictionary *)valuesFromNetworkResponse:(NSDictionary *)response
{
    NSMutableDictionary *values = [NSMutableDictionary dictionary];

    values[@"fileId"] = response[@"id"];
    values[@"filename"] = response[@"name"];
    values[@"title"] = response[@"title"];
    values[@"mimeType"] = response[@"mimetype"];
    values[@"prettyType"] = response[@"pretty_type"];

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

@end
