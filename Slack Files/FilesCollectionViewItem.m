//
//  FilesCollectionViewItem.m
//  Slack Files
//
//  Created by Chris DeSalvo on 6/5/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

#import "FilesCollectionViewItem.h"

#import "File.h"

static NSDateFormatter              *gDateFormatter;
static NSURLSessionConfiguration    *gNetworkConfiguration;

@interface FilesCollectionViewItem ()

@property   IBOutlet    NSImageView *iconView;
@property   IBOutlet    NSTextField *titleView;
@property   IBOutlet    NSTextField *dateView;

@property   NSURLSession            *networkSession;
@property   NSURLSessionDataTask    *iconTask;

@end

@implementation FilesCollectionViewItem

+ (void)initialize
{
    gDateFormatter = [NSDateFormatter new];

    gDateFormatter.dateStyle = NSDateFormatterMediumStyle;
    gDateFormatter.timeStyle = NSDateFormatterShortStyle;
    gDateFormatter.timeZone = [NSTimeZone localTimeZone];

    gNetworkConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];

    gNetworkConfiguration.TLSMinimumSupportedProtocol = kTLSProtocol12;
    gNetworkConfiguration.HTTPMaximumConnectionsPerHost = 1;
    gNetworkConfiguration.HTTPShouldUsePipelining = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.wantsLayer = YES;
    self.view.layer.borderColor = [NSColor lightGrayColor].CGColor;
    self.view.layer.borderWidth = 1.0;
    self.view.layer.cornerRadius = 8.0;

    [self configureNetworkSession];
}

- (void)configureWithFile:(File *)file
{
    self.iconView.image = [file filesystemIcon];
    self.titleView.stringValue = file.title;

    self.dateView.stringValue = [gDateFormatter stringFromDate:file.creationDate];

    if (IsStringWithContents(file.thumbnailURL))
    {
        NSURL   *iconURL = [NSURL URLWithString:file.thumbnailURL];

        self.iconTask = [self.networkSession dataTaskWithURL:iconURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

            if (data)
            {
                NSImage *image = [[NSImage alloc] initWithData:data];

                dispatch_async(dispatch_get_main_queue(), ^{

                    self.iconView.image = image;
                });
            }
        }];

        [self.iconTask resume];
    }
}

- (void)prepareForReuse
{
    [self.iconTask cancel];
    self.iconTask = nil;
}

- (void)configureNetworkSession
{
    if (self.networkSession)
    {
        return;
    }

    self.networkSession = [NSURLSession sessionWithConfiguration:gNetworkConfiguration];
}

@end
