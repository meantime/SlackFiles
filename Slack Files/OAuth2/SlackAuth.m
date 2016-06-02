//
//  SlackAuth.m
//  Slack Files
//
//  Created by Chris DeSalvo on 5/30/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

@import AppKit;

#import "SlackAuth.h"

#import "AuthWindowController.h"
#import "NSURL+QueryArgs.h"

static NSString *kClientId          = @"xxxxx.xxxxx";
static NSString *kClientSecret      = @"xxxxxxxxxxx";
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

@interface SlackAuth () <AuthWindowDelegate>

@property (nonnull, copy)   NSString                *uniqueId;
@property (nullable)        AuthWindowController    *authWindowController;
@property (nullable)        NSDictionary            *authResponse;

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

    NSURLRequest    *request = [NSURLRequest requestWithURL:c.URL];

    self.authWindowController = [AuthWindowController authWindowController];
    self.authWindowController.delegate = self;
    [self.authWindowController startAuthSessionWithRequest:request];
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

    [self.authWindowController startAccessSessionWithRequest:[NSURLRequest requestWithURL:url]];
}

- (void)shutDownAuthWindow
{
    [self.authWindowController finishSession];
    self.authWindowController = nil;
}

#pragma mark - <AuthWindowDelegate>

- (void)authWindow:(nonnull AuthWindowController *)windowController didReceiveURLResponse:(nonnull NSURL *)url
{
    NSDictionary    *args = [url dictionaryFromQueryArgs];

    [self processAuthResponse:args];
}

- (void)authWindow:(nonnull AuthWindowController *)windowController didReceiveJSONResponse:(nonnull NSString *)jsonString
{
    NSData          *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary    *args = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

    self.authResponse = args;

    [self shutDownAuthWindow];
}

- (void)authWindow:(nonnull AuthWindowController *)windowController didReceiveTextResponse:(nonnull NSString *)text
{
    NSLog(@"%@", text);
}

- (void)authWindow:(nonnull AuthWindowController *)windowController didReceiveErrorResponse:(nonnull NSError *)error
{
    NSAlert *alert = [NSAlert alertWithError:error];

    [alert runModal];
}

- (void)authWindowCanceledByUser:(nonnull AuthWindowController *)windowController
{
    [self shutDownAuthWindow];
}

@end
