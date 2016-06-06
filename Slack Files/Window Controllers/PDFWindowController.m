//
//  PDFWindowController.m
//  Slack Files
//
//  Created by Chris DeSalvo on 6/6/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

#import "PDFWindowController.h"

@import Quartz;

#import "File.h"
#import "Team.h"

@interface PDFWindowController () <NSWindowDelegate>

@property   IBOutlet    PDFView     *pdfView;
@property               File        *file;

@property   NSURLSession            *networkSession;
@property   NSURLSessionDataTask    *networkTask;

@end

@implementation PDFWindowController

+ (instancetype)windowControllerForFile:(File *)file
{
    PDFWindowController *result = [[PDFWindowController alloc] initWithWindowNibName:@"PDFWindowController"];

    result.file = file;

    return result;
}

- (void)windowDidLoad
{
    [super windowDidLoad];

    self.window.title = self.file.title;
    self.window.delegate = self;

    [self loadPDFContent];
}

- (void)loadPDFContent
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
            dispatch_async(dispatch_get_main_queue(), ^{

                PDFDocument *document = [[PDFDocument alloc] initWithData:data];

                self.pdfView.document = document;
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
