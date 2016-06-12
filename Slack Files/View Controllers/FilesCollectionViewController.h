//
//  FilesCollectionViewController.h
//  Slack Files
//
//  Created by Chris DeSalvo on 6/5/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

@import Cocoa;

#import "FilesWindowController.h"
#import "ChannelFilterViewController.h"

@class Team;

@interface FilesCollectionViewController : NSViewController<ChannelFilterDelegate, SyncUIDelegate>

@property   IBOutlet    NSCollectionView        *collectionView;

+ (instancetype)viewControllerForTeam:(Team *)team;

@end
