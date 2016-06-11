//
//  SlackModelObject.m
//  Slack Files
//
//  Created by Chris DeSalvo on 6/11/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

#import "SlackModelObject.h"

@implementation SlackModelObject

+ (NSDictionary *)valuesFromNetworkResponse:(NSDictionary *)response
{
    NSMutableDictionary *values = [NSMutableDictionary dictionary];

    values[@"jsonBlob"] = [NSJSONSerialization dataWithJSONObject:response options:0 error:nil];

    return [NSDictionary dictionaryWithDictionary:values];
}

@end
