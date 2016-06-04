//
//  AuthWindowController.m
//  Slack Files
//
//  Created by Chris DeSalvo on 6/1/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

@import WebKit;

#import "AuthWindowController.h"

static NSString *kFetchTextContents = @"document.documentElement.outerText;";

NS_ENUM(NSUInteger, AuthResponseType)
{
    AuthResponseTypeUnknown,
    AuthResponseTypeHTML,
    AuthResponseTypeJSON,
    AuthResponseTypeText
};

@interface AuthWindowController () <WKNavigationDelegate>

@property WKWebView *webview;

@property (nonatomic, assign)   enum AuthResponseType   responseType;

@end

@implementation AuthWindowController

+ (nullable instancetype)authWindowController
{
    return [[AuthWindowController alloc] initWithWindowNibName:@"AuthWindowController"];
}

- (void)windowDidLoad
{
    [super windowDidLoad];

    NSView                  *content = [self.window contentView];
    WKWebViewConfiguration  *config = [WKWebViewConfiguration new];
    WKPreferences           *prefs = [WKPreferences new];

    prefs.javaScriptEnabled = YES;
    prefs.javaScriptCanOpenWindowsAutomatically = NO;
    prefs.javaEnabled = NO;
    prefs.plugInsEnabled = NO;

    config.preferences = prefs;

    self.webview = [[WKWebView alloc] initWithFrame:content.frame configuration:config];
    self.webview.allowsBackForwardNavigationGestures = NO;
    self.webview.navigationDelegate = self;

    [content addSubview:self.webview];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(windowWillClose:)
                                                 name:NSWindowWillCloseNotification
                                               object:self.window];
}

- (void)finishSession
{
    if (self.window)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:NSWindowWillCloseNotification
                                                      object:self.window];
    }

    [self.webview stopLoading];
    [self.window orderOut:nil];

    [self.webview removeFromSuperview];
    self.webview = nil;
}

- (void)startAuthSessionWithRequest:(nonnull NSURLRequest *)request
{
    [self window];
    [self showWindow:self];

    self.responseType = AuthResponseTypeUnknown;
    [self.webview loadRequest:request];
}

- (void)windowWillClose:(NSNotification *)notification
{
    if (notification.object != self.window)
    {
        return;
    }

    if ([self.delegate respondsToSelector:@selector(authWindowCanceledByUser:)])
    {
        [self.delegate authWindowCanceledByUser:self];
        [self finishSession];
    }
}

#pragma mark - <WKNavigationDelegate>

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSLog(@"decidePolicyForNavigationAction:%@", navigationAction);

    WKNavigationActionPolicy    response = WKNavigationActionPolicyAllow;
    NSURL                       *url = navigationAction.request.URL;
    NSURLComponents             *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];

    if ([@"slackfiles" isEqualToString:components.scheme])
    {
        if ([self.delegate respondsToSelector:@selector(authWindow:didReceiveURLResponse:)])
        {
            [self.delegate authWindow:self didReceiveURLResponse:url];
            response = WKNavigationActionPolicyCancel;
        }
    }

    decisionHandler(response);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    NSLog(@"decidePolicyForNavigationResponse:%@", navigationResponse);

    NSString    *responseMIMEType = navigationResponse.response.MIMEType;

    if ([responseMIMEType isEqualToString:@"text/html"])
    {
        self.responseType = AuthResponseTypeHTML;
    }
    else if ([responseMIMEType isEqualToString:@"application/json"])
    {
        self.responseType = AuthResponseTypeJSON;
        self.webview.hidden = YES;
    }
    else if ([responseMIMEType isEqualToString:@"text/plain"])
    {
        self.responseType = AuthResponseTypeText;
        self.webview.hidden = YES;
    }
    else
    {
        self.responseType = AuthResponseTypeUnknown;
    }

    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    NSLog(@"didStartProvisionalNavigation:");
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    NSLog(@"didReceiveServerRedirectForProvisionalNavigation:");
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"didFailProvisionalNavigation:");
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation
{
    NSLog(@"didCommitNavigation:");
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    NSLog(@"didFinishNavigation:");

    if (AuthResponseTypeJSON == self.responseType)
    {
        __block NSString    *jsonString = nil;

        [self.webview evaluateJavaScript:kFetchTextContents completionHandler:^(id _Nullable result, NSError * _Nullable error) {

            if (IsStringWithContents(result))
            {
                jsonString = (NSString *) result;

                if ([self.delegate respondsToSelector:@selector(authWindow:didReceiveJSONResponse:)])
                {
                    [self.delegate authWindow:self didReceiveJSONResponse:jsonString];
                }
            }
        }];
    }
    else if (AuthResponseTypeText == self.responseType)
    {
        __block NSString    *textString = nil;

        [self.webview evaluateJavaScript:kFetchTextContents completionHandler:^(id _Nullable result, NSError * _Nullable error) {

            if (IsStringWithContents(result))
            {
                textString = (NSString *) result;

                if ([self.delegate respondsToSelector:@selector(authWindow:didReceiveTextResponse:)])
                {
                    [self.delegate authWindow:self didReceiveTextResponse:textString];
                }
            }
        }];
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"didFailNavigation:");
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *__nullable credential))completionHandler
{
    NSLog(@"didReceiveAuthenticationChallenge:%@", challenge);
    completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView
{
    NSLog(@"webViewWebContentProcessDidTerminate:");
}

@end
