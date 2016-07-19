//
//  FilesCollectionViewItem.m
//  Slack Files
//
//  Created by Chris DeSalvo on 6/5/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

#import "FilesCollectionViewItem.h"

#import "File.h"
#import "FileCollectionViewItemView.h"

static NSDateFormatter              *gDateFormatter;
static NSURLSessionConfiguration    *gNetworkConfiguration;

@interface FilesCollectionViewItem ()

@property   IBOutlet    NSImageView *iconView;
@property   IBOutlet    NSTextField *titleView;
@property   IBOutlet    NSTextField *dateView;
@property   IBOutlet    NSTextField *sizeView;

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

    [self configureNetworkSession];
}

- (void)setHighlightState:(NSCollectionViewItemHighlightState)newHighlightState
{
    [super setHighlightState:newHighlightState];

    [(FileCollectionViewItemView *) [self view] setHighlightState:newHighlightState];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];

    [(FileCollectionViewItemView *) [self view] setSelected:selected];
}

- (void)configureWithFile:(File *)file
{
    FileCollectionViewItemView  *view = (FileCollectionViewItemView *) self.view;

    view.file = file;

    self.iconView.image = [file filesystemIcon];
    self.titleView.stringValue = file.title;
    self.view.toolTip = file.title;
    
    self.dateView.stringValue = [gDateFormatter stringFromDate:file.timestamp];
    self.sizeView.stringValue = [NSByteCountFormatter stringFromByteCount:file.filesize.unsignedIntegerValue countStyle:NSByteCountFormatterCountStyleFile];
    
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
    self.view.toolTip = nil;
    
    self.iconView.image = nil;
    
    [self.iconTask cancel];
    self.iconTask = nil;

    [self setSelected:NO];
    [self setHighlightState:NSCollectionViewItemHighlightNone];
}

- (void)configureNetworkSession
{
    if (self.networkSession)
    {
        return;
    }

    self.networkSession = [NSURLSession sessionWithConfiguration:gNetworkConfiguration];
}

- (NSImage *)dragImage
{
    return self.iconView.image;
}

@end
