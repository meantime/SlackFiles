//
//  SlackAuth.m
//  Slack Files
//
//  Created by Chris DeSalvo on 5/30/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

@import AppKit;

#import "SlackAuth.h"

#import "NSURL+QueryArgs.h"

static NSString *kClientId          = @"xxxxxxx.xxxxxxx";
static NSString *kClientSecret      = @"xxxxxxxxxxxxxxx";
static NSString *kAuthEndpoint      = @"https://slack.com/oauth/authorize";
static NSString *kAccessEndpoint    = @"https://slack.com/api/oauth.access";
static NSString *kRedirectURI       = @"slackfiles://authendpoint";
static NSString *kScope             = @"channels:read files:read groups:read im:read mpim:read team:read users:read";

static NSString *kClientIdArg       = @"client_id";
static NSString *kClientSecretArg   = @"client_secret";
static NSString *kScopeArg          = @"scope";
static NSString *kRedirectArg       = @"redirect_uri";
static NSString *kStateArg          = @"state";
static NSString *kCodeArg           = @"code";

@interface SlackAuth ()

@property (copy, readwrite)     NSString                *uniqueId;
@property (nullable, strong)    NSURLSession            *networkSession;
@property (nullable, strong)    NSURLSessionDataTask    *accessTask;

@end

@implementation SlackAuth

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        self.uniqueId = [[NSUUID UUID] UUIDString];
    }

    return self;
}

- (void)configureNetworkSession
{
    NSURLSessionConfiguration   *networkConfig = [NSURLSessionConfiguration defaultSessionConfiguration];

    networkConfig.TLSMinimumSupportedProtocol = kTLSProtocol12;
    networkConfig.HTTPMaximumConnectionsPerHost = 5;
    networkConfig.HTTPShouldUsePipelining = YES;

    self.networkSession = [NSURLSession sessionWithConfiguration:networkConfig];
}

- (void)run
{
    NSURLComponents *c = [NSURLComponents componentsWithString:kAuthEndpoint];
    NSMutableArray  *args = [NSMutableArray array];
    NSURLQueryItem  *arg;

    arg = [NSURLQueryItem queryItemWithName:kClientIdArg value:kClientId];
    [args addObject:arg];

    arg = [NSURLQueryItem queryItemWithName:kScopeArg value:kScope];
    [args addObject:arg];

    arg = [NSURLQueryItem queryItemWithName:kRedirectArg value:kRedirectURI];
    [args addObject:arg];

    arg = [NSURLQueryItem queryItemWithName:kStateArg value:[NSString stringWithFormat:@"%@-auth", self.uniqueId]];
    [args addObject:arg];

    c.queryItems = args;

    NSURL   *url = c.URL;

    [[NSWorkspace sharedWorkspace] openURL:url];
}

- (void)processResponse:(nonnull NSURL *)response
{
    NSDictionary    *args = [response dictionaryFromQueryArgs];
    NSString        *state = args[kStateArg];

    if (NO == [state hasPrefix:self.uniqueId])
    {
        return;
    }

    if ([state hasSuffix:@"auth"])
    {
        [self processAuthResponse:args];
    }
    else if ([state hasSuffix:@"access"])
    {
        [self processAccessResponse:args];
    }
}

- (void)processAuthResponse:(nonnull NSDictionary *)response
{
    NSURLComponents *c = [NSURLComponents componentsWithString:kAccessEndpoint];
    NSMutableArray  *args = [NSMutableArray array];
    NSURLQueryItem  *arg;

    arg = [NSURLQueryItem queryItemWithName:kClientIdArg value:kClientId];
    [args addObject:arg];

    arg = [NSURLQueryItem queryItemWithName:kClientSecretArg value:kClientSecret];
    [args addObject:arg];

    arg = [NSURLQueryItem queryItemWithName:kCodeArg value:response[kCodeArg]];
    [args addObject:arg];

    arg = [NSURLQueryItem queryItemWithName:kRedirectArg value:kRedirectURI];
    [args addObject:arg];

    arg = [NSURLQueryItem queryItemWithName:kStateArg value:[NSString stringWithFormat:@"%@-access", self.uniqueId]];
    [args addObject:arg];

    c.queryItems = args;

    NSURL   *url = c.URL;

    if (nil == self.networkSession)
    {
        [self configureNetworkSession];
    }

    self.accessTask = [self.networkSession dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        dispatch_async(dispatch_get_main_queue(), ^ {

            [self processAccessResponse:response data:data error:error];
        });
    }];

    [self.accessTask resume];
}

- (void)processAccessResponse:(nonnull NSDictionary *)response
{
    NSLog(@"%@", response);
}

- (void)processAccessResponse:(nonnull NSURLResponse *)response data:(nullable NSData *)data error:(nullable NSError *)error
{
    NSHTTPURLResponse   *r = (NSHTTPURLResponse *) response;

    if (200 == r.statusCode)
    {
        if (data)
        {
            NSDictionary    *args = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

            NSLog(@"%@", args);
        }
    }
    else if (error)
    {
        NSAlert *alert = [NSAlert alertWithError:error];

        [alert runModal];
    }

    self.accessTask = nil;
}

@end
