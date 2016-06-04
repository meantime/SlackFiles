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

@interface SlackAPI ()

@property (nullable, strong)    NSURLSession            *networkSession;
@property (nullable, strong)    NSURLSessionDataTask    *activeTask;
@property (nonnull, strong)     NSMutableArray          *pendingTasks;

@end

@implementation SlackAPI

- (instancetype)init
{
    return [self initWithTeam:nil];
}

- (instancetype)initWithTeam:(nullable Team *)team
{
    self = [super init];

    if (self)
    {
        self.team = team;
        self.pendingTasks = [NSMutableArray array];
    }

    return self;
}

- (NSURLRequest *)requestForEndpoint:(NSString *)endpoint arguments:(nullable NSDictionary *)args
{
    if (IsStringWithContents(self.team.apiToken))
    {
        NSMutableDictionary  *a = [NSMutableDictionary dictionary];

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
    [self configureNetworkSession];

    NSURLRequest            *request = [self requestForEndpoint:endpoint arguments:args];
    NSURLSessionDataTask    *accessTask = [self.networkSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        if (completion)
        {
            dispatch_async(dispatch_get_main_queue(), ^ {

                NSDictionary    *result = nil;

                if (data && data.length > 0)
                {
                    result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                }

                completion(result, error);
            });
        }

        self.activeTask = nil;
        [self dispatchNextTask];
    }];

    [self.pendingTasks addObject:accessTask];
    [self dispatchNextTask];
}

- (void)dispatchNextTask
{
    if (self.activeTask)
    {
        return;
    }

    self.activeTask = [self.pendingTasks firstObject];

    if (self.activeTask)
    {
        [self.pendingTasks removeObjectAtIndex:0];
        [self.activeTask resume];
    }
}

- (void)configureNetworkSession
{
    if (self.networkSession)
    {
        return;
    }
    
    NSURLSessionConfiguration   *networkConfig = [NSURLSessionConfiguration defaultSessionConfiguration];

    networkConfig.TLSMinimumSupportedProtocol = kTLSProtocol12;
    networkConfig.HTTPMaximumConnectionsPerHost = 5;
    networkConfig.HTTPShouldUsePipelining = YES;

    self.networkSession = [NSURLSession sessionWithConfiguration:networkConfig];
}

@end

NS_ASSUME_NONNULL_END
