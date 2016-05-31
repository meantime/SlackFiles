//
//  NSURL+QueryArgs.m
//  Slack Files
//
//  Created by Chris DeSalvo on 5/30/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

#import "NSURL+QueryArgs.h"

@implementation NSURL (QueryArgs)

- (NSDictionary *)dictionaryFromQueryArgs
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSURLComponents     *components = [NSURLComponents componentsWithURL:self resolvingAgainstBaseURL:NO];
    NSArray             *args = [components queryItems];

    for (NSURLQueryItem *item in args)
    {
        result[item.name] = item.value;
    }

    return [NSDictionary dictionaryWithDictionary:result];
}

@end
