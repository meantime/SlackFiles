//
//  FilesCollectionViewItem.h
//  Slack Files
//
//  Created by Chris DeSalvo on 6/5/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

@import Cocoa;

@class File;

@interface FilesCollectionViewItem : NSCollectionViewItem

- (void)configureWithFile:(File *)file;
- (NSImage *)dragImage;

@end
