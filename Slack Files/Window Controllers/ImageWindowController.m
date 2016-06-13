//
//  ImageWindowController.m
//  Slack Files
//
//  Created by Chris DeSalvo on 6/7/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

#import "ImageWindowController.h"

#import "File.h"

@interface ImageWindowController ()

@property   IBOutlet    NSImageView *imageView;
@property               NSData      *imageData;
@property               NSSavePanel *savePanel;

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

            self.imageData = data;
            self.window.maxSize = image.size;
            self.imageView.image = image;
        }
    }];
}

- (BOOL)validateUserInterfaceItem:(id < NSValidatedUserInterfaceItem >)anItem
{
    BOOL    result = NO;

    if ([anItem action] == @selector(copy:))
    {
        result = (nil != self.imageData);
    }
    else if ([anItem action] == @selector(saveDocument:) || [anItem action] == @selector(saveDocumentAs:))
    {
        result = (nil != self.imageData);
    }

    return result;
}

- (IBAction)copy:(id)sender
{
    NSPasteboard    *pasteboard = [NSPasteboard generalPasteboard];

    [pasteboard clearContents];
    [pasteboard writeObjects:@[ self.imageView.image ]];
}

- (IBAction)saveDocument:(id)sender
{
    [self saveDocumentAs:sender];
}

- (IBAction)saveDocumentAs:(id)sender
{
    self.savePanel = [NSSavePanel savePanel];

    self.savePanel.prompt = @"Save Image";
    self.savePanel.title = self.file.title;
    self.savePanel.nameFieldStringValue = self.file.filename;

    [self.savePanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {

        if (NSFileHandlingPanelOKButton == result)
        {
            NSURL   *url = self.savePanel.URL;

            [self.imageData writeToURL:url atomically:NO];
        }
    }];
}

@end
