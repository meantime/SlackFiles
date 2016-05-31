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
    NSString            *queryArgs = self.query;
    NSArray             *keyValuePairs = [queryArgs componentsSeparatedByString:@"&"];

    for (NSString *keyValuePair in keyValuePairs)
    {
        NSArray *kv = [keyValuePair componentsSeparatedByString:@"="];

        if (kv.count == 2)
        {
            NSString    *key = [kv[0] stringByRemovingPercentEncoding];
            NSString    *value = [kv[1] stringByRemovingPercentEncoding];

            result[key] = value;
        }
    }

    return [NSDictionary dictionaryWithDictionary:result];
}

@end
