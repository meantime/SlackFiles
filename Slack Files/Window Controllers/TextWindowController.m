//
//  TextWindowController.m
//  Slack Files
//
//  Created by Chris DeSalvo on 6/6/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

#import "TextWindowController.h"

#import "File.h"
#import "Team.h"

@interface TextWindowController () <NSWindowDelegate>

@property   IBOutlet    NSTextView              *textView;
@property               File                    *file;
@property               NSURLSession            *networkSession;
@property               NSURLSessionDataTask    *networkTask;

@end

@implementation TextWindowController

+ (instancetype)windowControllerForFile:(File *)file
{
    TextWindowController    *result = [[TextWindowController alloc] initWithWindowNibName:@"TextWindowController"];

    result.file = file;

    return result;
}

- (void)windowDidLoad
{
    [super windowDidLoad];

    self.window.title = self.file.title;
    self.window.delegate = self;

    self.textView.font = [NSFont systemFontOfSize:16.0];

    [self loadTextContent];
}

- (void)loadTextContent
{
    NSURLSessionConfiguration   *networkConfig = [NSURLSessionConfiguration defaultSessionConfiguration];

    networkConfig.TLSMinimumSupportedProtocol = kTLSProtocol12;
    networkConfig.HTTPMaximumConnectionsPerHost = 5;
    networkConfig.HTTPShouldUsePipelining = YES;

    self.networkSession = [NSURLSession sessionWithConfiguration:networkConfig];

    NSDictionary        *metadata = [NSJSONSerialization JSONObjectWithData:self.file.jsonBlob options:0 error:nil];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:metadata[@"url_private"]]];

    [request setValue:self.file.team.apiToken forHTTPHeaderField:@"Bearer"];

    self.networkTask = [self.networkSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        if (data)
        {
            NSString    *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

            dispatch_async(dispatch_get_main_queue(), ^{

                [self.textView.textStorage appendAttributedString:[[NSAttributedString alloc] initWithString:string]];
            });
        }
    }];

    [self.networkTask resume];
}

#pragma mark - <NSWindowDelegate>

- (BOOL)windowShouldClose:(id)sender
{
    [self.networkSession invalidateAndCancel];
    [NSAppDelegate windowWillClose:self];

    return YES;
}

@end
