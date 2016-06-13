//
//  WindowController.m
//  Slack Files
//
//  Created by Chris DeSalvo on 6/6/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

#import "WindowController.h"

#import "File.h"
#import "Team.h"

@interface WindowController () <NSWindowDelegate>

@property (nonnull, readwrite)  File    *file;
@property (nonnull, readwrite)  NSData  *fileData;

@property   NSURLSession                *networkSession;
@property   NSURLSessionDataTask        *networkTask;

@property   NSSavePanel                 *savePanel;

@end

@implementation WindowController

+ (instancetype)windowControllerForFile:(File *)file
{
    NSString    *nibName = NSStringFromClass(self);
    id          result = [[self alloc] initWithWindowNibName:nibName];

    [result setFile:file];

    return result;
}

- (void)windowDidLoad
{
    [super windowDidLoad];

    self.window.title = self.file.title;
    self.window.delegate = self;
}

- (void)loadContentWithCompletion:(void (^)(NSData * __nullable data, NSURLResponse * __nullable response, NSError * __nullable error))completionHandler
{
    NSURLSessionConfiguration   *networkConfig = [NSURLSessionConfiguration defaultSessionConfiguration];

    networkConfig.TLSMinimumSupportedProtocol = kTLSProtocol12;
    networkConfig.HTTPMaximumConnectionsPerHost = 1;
    networkConfig.HTTPShouldUsePipelining = YES;

    self.networkSession = [NSURLSession sessionWithConfiguration:networkConfig];

    NSDictionary        *metadata = [NSJSONSerialization JSONObjectWithData:self.file.jsonBlob options:0 error:nil];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:metadata[@"url_private"]]];

    [request setValue:self.file.team.apiToken forHTTPHeaderField:@"Bearer"];

    self.networkTask = [self.networkSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        if (completionHandler)
        {
            dispatch_async(dispatch_get_main_queue(), ^{

                self.fileData = data;

                completionHandler(data, response, error);
            });
        }
    }];
    
    [self.networkTask resume];
}

- (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)anItem
{
    BOOL    result = NO;

    if ([anItem action] == @selector(saveDocument:) || [anItem action] == @selector(saveDocumentAs:))
    {
        result = (nil != self.fileData);
    }

    return result;
}

- (IBAction)saveDocument:(id)sender
{
    [self saveDocumentAs:sender];
}

- (IBAction)saveDocumentAs:(id)sender
{
    self.savePanel = [NSSavePanel savePanel];

    self.savePanel.title = self.file.title;
    self.savePanel.nameFieldStringValue = self.file.filename;

    [self.savePanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {

        if (NSFileHandlingPanelOKButton == result)
        {
            NSURL   *url = self.savePanel.URL;

            [self.fileData writeToURL:url atomically:NO];
        }
    }];
}

#pragma mark - <NSWindowDelegate>

- (BOOL)windowShouldClose:(id)sender
{
    [self.networkSession invalidateAndCancel];

    self.networkSession = nil;
    self.networkTask = nil;

    [NSAppDelegate windowWillClose:self];

    return YES;
}

@end
