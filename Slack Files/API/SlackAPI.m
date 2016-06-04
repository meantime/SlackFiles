//
//  SlackAPI.m
//  Slack Files
//
//  Created by Chris DeSalvo on 6/3/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

#import "SlackAPI.h"
#import "Team.h"

NS_ASSUME_NONNULL_BEGIN

const struct SlackEndpoints SlackEndpoints =
{
    .channelsList       = @"channels.list",
    .filesInfo          = @"files.info",
    .filesList          = @"files.list",
    .groupsInfo         = @"groups.info",
    .groupsList         = @"groups.list",
    .imList             = @"im.list",
    .mpimList           = @"mpim.list",
    .oauthAccess        = @"oauth.access",
    .teamInfo           = @"team.info",
    .usersInfo          = @"users.info",
    .usersList          = @"users.list"
};

@implementation SlackAPI

- (NSURLRequest *)requestForEndpoint:(NSString *)endpoint arguments:(nullable NSDictionary *)args
{
    if (IsStringWithContents(self.team.apiToken))
    {
        NSMutableDictionary  *a = [args mutableCopy];

        if (args)
        {
            [a addEntriesFromDictionary:args];
        }

        a[@"token"] = self.team.apiToken;

        args = [NSDictionary dictionaryWithDictionary:a];
    }

    NSString        *urlString = [NSString stringWithFormat:@"https://slack.com/api/%@", endpoint];
    NSURLComponents *components = [NSURLComponents componentsWithString:urlString];

    if (args.count > 0)
    {
        NSMutableArray  *a = [NSMutableArray arrayWithCapacity:args.count];

        for (NSString *key in args.allKeys)
        {
            NSURLQueryItem  *i = [NSURLQueryItem queryItemWithName:key value:args[key]];

            [a addObject:i];
        }

        components.queryItems = a;
    }

    return [NSURLRequest requestWithURL:components.URL];
}

- (void)callEndpoint:(NSString *)endpoint withArguments:(nullable NSDictionary *)args completion:(APICompletionBlock)completion
{
    NSURLRequest    *request = [self requestForEndpoint:endpoint arguments:args];

    NSLog(@"%@", request);
}

@end

NS_ASSUME_NONNULL_END
