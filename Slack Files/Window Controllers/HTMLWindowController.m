//
//  HTMLWindowController.m
//  Slack Files
//
//  Created by Chris DeSalvo on 6/10/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

#import "HTMLWindowController.h"

@import WebKit;

#import "File.h"

@interface HTMLWindowController ()

@property WKWebView *webview;

@end

@implementation HTMLWindowController

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
    self.webview.autoresizingMask = NSViewMinXMargin | NSViewWidthSizable | NSViewMaxXMargin | NSViewMinYMargin | NSViewHeightSizable | NSViewMaxYMargin;

    [content addSubview:self.webview];

    [self loadHTMLContent];
}

- (void)loadHTMLContent
{
    [self loadContentWithCompletion:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        if (data)
        {
            [self.webview loadData:data MIMEType:self.file.mimeType characterEncodingName:@"UTF-8" baseURL:[NSURL URLWithString:@""]];
        }
    }];
}

@end
