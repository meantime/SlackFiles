//
//  SlackAPI.m
//  Slack Files
//
//  Created by Chris DeSalvo on 6/3/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

#import "SlackAPI.h"

@import SocketRocket;

#import "RealtimeDelegate.h"
#import "SlackRealtimeMessageDelegate.h"
#import "Team.h"

NS_ASSUME_NONNULL_BEGIN

const struct SlackEndpoints SlackEndpoints =
{
    .channelsList       = @"channels.list",
    .filesInfo          = @"files.info",
    .filesList          = @"files.list",
    .filesShare         = @"files.share",
    .groupsInfo         = @"groups.info",
    .groupsList         = @"groups.list",
    .imList             = @"im.list",
    .mpimList           = @"mpim.list",
    .oauthAccess        = @"oauth.access",
    .rtmLeanStart       = @"rtm.leanStart",
    .rtmStart           = @"rtm.start",
    .teamInfo           = @"team.info",
    .usersInfo          = @"users.info",
    .usersList          = @"users.list"
};

@interface SlackAPI () <SRWebSocketDelegate>

@property (nullable, strong)    NSURLSession            *networkSession;
@property (nullable, strong)    NSURLSessionDataTask    *activeTask;
@property (nonnull, strong)     NSMutableArray          *pendingTasks;
@property (copy)                NSString                *teamId;
@property (copy)                NSString                *apiToken;
@property (nullable, strong)    SRWebSocket             *websocket;
@property (nullable, strong)    RealtimeDelegate        *realtimeDelegate;

@property (nullable, nonatomic, strong) dispatch_queue_t    messageProcessingQueue;

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
        if (team)
        {
            self.teamId = team.teamId;
            self.apiToken = team.apiToken;
        }

        self.pendingTasks = [NSMutableArray array];
    }

    return self;
}

- (void)dealloc
{
    [self closeRealtimeSocket];
}

- (NSURLRequest *)requestForEndpoint:(NSString *)endpoint arguments:(nullable NSDictionary *)args
{
    if (IsStringWithContents(self.apiToken))
    {
        NSMutableDictionary  *a = [NSMutableDictionary dictionary];

        if (args)
        {
            [a addEntriesFromDictionary:args];
        }

        a[@"token"] = self.apiToken;

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

                if (data.length > 0)
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

- (void)suspend
{
    [self.activeTask suspend];
}

- (void)resume
{
    if (self.activeTask)
    {
        [self.activeTask resume];
    }
    else
    {
        [self dispatchNextTask];
    }

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

#pragma mark - Realtime Support

- (void)openRealtimeSocket
{
    if (self.websocket)
    {
        return;
    }

    NSDictionary    *args = @{ @"features"              : @"0",
                               @"include_full_users"    : @"0",
                               @"no_subteams"           : @"1",
                               @"only_relevant_ims"     : @"1",
                               @"eac_cache_ts"          : @"0",
                               @"canonical_avatars"     : @"0",
                               @"name_tagging"          : @"0" };

    [self callEndpoint:SlackEndpoints.rtmLeanStart withArguments:args completion:^(NSDictionary * _Nullable result, NSError * _Nullable error) {

        if ([result[@"ok"] boolValue])
        {
            NSURL           *url = [NSURL URLWithString:result[@"url"]];
            NSURLRequest    *request = [NSURLRequest requestWithURL:url];

            self.websocket = [[SRWebSocket alloc] initWithURLRequest:request];
            self.realtimeDelegate = [[RealtimeDelegate alloc] initWithTeamId:self.teamId];
            [self.realtimeDelegate setAPI:self];
            self.websocket.delegate = self.realtimeDelegate;

            [self.websocket open];
        }
    }];
}

- (void)closeRealtimeSocket
{
    [self.websocket close];
    self.websocket = nil;
    self.realtimeDelegate = nil;
}

#pragma mark - <SRWebSocketDelegate>

- (void)closeProcessingQueue
{
    self.messageProcessingQueue = 0;
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    NSLog(@"webSocketDidOpen for team %@", self.teamId);
    
    dispatch_queue_attr_t   attributes = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, 0);
    NSString                *queueName = [NSString stringWithFormat:@"%@ realtime queue", self.teamId];
    
    self.messageProcessingQueue = dispatch_queue_create(queueName.UTF8String, attributes);
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    NSLog(@"webSocketDidFailWithError for team %@, %@", self.teamId, error);
    
    [self closeProcessingQueue];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(nullable NSString *)reason wasClean:(BOOL)wasClean
{
    NSLog(@"webSocketDidCloseWithCode for team %@, code %ld, reason %@, was clean %d", self.teamId, code, reason, wasClean);
    [self closeProcessingQueue];
}

- (BOOL)webSocketShouldConvertTextFrameToString:(SRWebSocket *)webSocket
{
    //  Have to do this to force everything to be piped through didReceiveMessageWithData
    return NO;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(nullable NSData *)pongData
{
    if (nil == pongData)
    {
        return;
    }
    
    NSDictionary    *pong = [NSJSONSerialization JSONObjectWithData:pongData options:0 error:nil];
    
    NSLog(@"webSocket didReceivePong: %@", pong);
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessageWithData:(NSData *)data
{
    if (nil == self.realtimeDelegate)
    {
        return;
    }
    
    dispatch_async(self.messageProcessingQueue, ^{
        
        NSDictionary    *message = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSString        *type = message[@"type"];
        
        if ([@"hello" isEqualToString:type])
        {
            if ([self.realtimeMessageDelegate respondsToSelector:@selector(slackAPIDidMakeRealtimeConnection:)])
            {
                [self.realtimeMessageDelegate slackAPIDidMakeRealtimeConnection:self];
            }
        }
        else if ([@"file_created" isEqualToString:type])
        {
            if ([self.realtimeMessageDelegate respondsToSelector:@selector(slackAPI:didCreateFileWithId:)])
            {
                [self.realtimeMessageDelegate slackAPI:self
                                   didCreateFileWithId:[message valueForKeyPath:@"file.id"]];
            }
        }
        else if ([@"file_shared" isEqualToString:type])
        {
            if ([self.realtimeMessageDelegate respondsToSelector:@selector(slackAPI:didShareFileWithId:)])
            {
                [self.realtimeMessageDelegate slackAPI:self
                                    didShareFileWithId:[message valueForKeyPath:@"file.id"]];
            }
        }
        else if ([@"file_unshared" isEqualToString:type])
        {
            if ([self.realtimeMessageDelegate respondsToSelector:@selector(slackAPI:didUnshareFileWithId:)])
            {
                [self.realtimeMessageDelegate slackAPI:self
                                  didUnshareFileWithId:[message valueForKeyPath:@"file.id"]];
            }
        }
        else if ([@"file_change" isEqualToString:type])
        {
            if ([self.realtimeMessageDelegate respondsToSelector:@selector(slackAPI:didChangeFileWithId:)])
            {
                [self.realtimeMessageDelegate slackAPI:self
                                   didChangeFileWithId:[message valueForKeyPath:@"file.id"]];
            }
        }
        else if ([@"file_deleted" isEqualToString:type])
        {
            if ([self.realtimeMessageDelegate respondsToSelector:@selector(slackAPI:didDeleteFileWithId:)])
            {
                [self.realtimeMessageDelegate slackAPI:self
                                   didDeleteFileWithId:message[@"file_id"]];
            }
        }
        else
        {
            NSLog(@"Ignoring message of type: %@", type);
        }
    });
}

@end

NS_ASSUME_NONNULL_END
