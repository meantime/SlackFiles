//
//  User.m
//  Slack Files
//
//  Created by Chris DeSalvo on 6/11/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

#import "User.h"

@implementation User

+ (NSString *)primaryKey
{
    return @"userId";
}

+ (NSDictionary *)valuesFromNetworkResponse:(NSDictionary *)response
{
    NSMutableDictionary *values = [NSMutableDictionary dictionary];
    NSDictionary        *profile = response[@"profile"];

    values[@"userId"] = response[@"id"];
    values[@"username"] = response[@"name"];
    values[@"realName"] = profile[@"real_name"];
    values[@"title"] = profile[@"title"];
    values[@"profileImageURL"] = [User bestImageURLFromProfileInfo:profile];
    values[@"jsonBlob"] = [NSJSONSerialization dataWithJSONObject:response options:0 error:nil];

    return [NSDictionary dictionaryWithDictionary:values];

}

+ (NSString *)bestImageURLFromProfileInfo:(NSDictionary *)profile
{
#define TryIconNamed(x) { if (IsStringWithContents(profile[(x)])) return profile[(x)]; }

    TryIconNamed(@"image_512");
    TryIconNamed(@"image_256");
    TryIconNamed(@"image_192");
    TryIconNamed(@"image_1024");
    TryIconNamed(@"image_original");
    TryIconNamed(@"image_72");
    TryIconNamed(@"image_48");
    TryIconNamed(@"image_32");
    TryIconNamed(@"image_24");

#undef TryIconNamed

    return @"";
}

@end