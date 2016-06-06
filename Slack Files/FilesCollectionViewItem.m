//
//  FilesCollectionViewItem.m
//  Slack Files
//
//  Created by Chris DeSalvo on 6/5/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

#import "FilesCollectionViewItem.h"

#import "File.h"

@interface FilesCollectionViewItem ()

@property   IBOutlet    NSImageView *iconView;
@property   IBOutlet    NSTextField *titleView;
@property   IBOutlet    NSTextField *dateView;

@end

@implementation FilesCollectionViewItem

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

    NSDateFormatter *formatter = [NSDateFormatter new];

    formatter.dateStyle = NSDateFormatterMediumStyle;
    formatter.timeStyle = NSDateFormatterMediumStyle;
    formatter.timeZone = [NSTimeZone localTimeZone];

    self.dateView.stringValue = [formatter stringFromDate:file.creationDate];

}

@end
