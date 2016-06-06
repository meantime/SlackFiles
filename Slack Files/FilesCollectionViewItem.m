//
//  FilesCollectionViewItem.m
//  Slack Files
//
//  Created by Chris DeSalvo on 6/5/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

#import "FilesCollectionViewItem.h"

#import "File.h"

static NSDateFormatter  *gDateFormatter;

@interface FilesCollectionViewItem ()

@property   IBOutlet    NSImageView *iconView;
@property   IBOutlet    NSTextField *titleView;
@property   IBOutlet    NSTextField *dateView;

@end

@implementation FilesCollectionViewItem

+ (void)initialize
{
    gDateFormatter = [NSDateFormatter new];

    gDateFormatter.dateStyle = NSDateFormatterMediumStyle;
    gDateFormatter.timeStyle = NSDateFormatterShortStyle;
    gDateFormatter.timeZone = [NSTimeZone localTimeZone];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.wantsLayer = YES;
    self.view.layer.borderColor = [NSColor lightGrayColor].CGColor;
    self.view.layer.borderWidth = 1.0;
    self.view.layer.cornerRadius = 8.0;
}

- (void)configureWithFile:(File *)file
{
    self.iconView.image = [file filesystemIcon];
    self.titleView.stringValue = file.title;

    self.dateView.stringValue = [gDateFormatter stringFromDate:file.creationDate];
}

@end
