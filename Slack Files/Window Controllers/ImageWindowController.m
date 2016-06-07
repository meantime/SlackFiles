//
//  ImageWindowController.m
//  Slack Files
//
//  Created by Chris DeSalvo on 6/7/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

#import "ImageWindowController.h"

@interface ImageWindowController ()

@property   IBOutlet    NSImageView *imageView;

@end

@implementation ImageWindowController

- (void)windowDidLoad
{
    [super windowDidLoad];

    NSView  *view = [self.window contentView];

    view.wantsLayer = YES;
    view.layer.backgroundColor = [NSColor blackColor].CGColor;

    [self loadImageContent];
}

- (void)loadImageContent
{
    [self loadContentWithCompletion:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        if (data)
        {
            NSImage *image = [[NSImage alloc] initWithData:data];

            self.window.maxSize = image.size;
            self.imageView.image = image;
        }
    }];
}

@end
