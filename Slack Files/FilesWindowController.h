//
//  FilesWindowController.h
//  Slack Files
//
//  Created by Chris DeSalvo on 6/4/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

@import Cocoa;

@class Team;

NS_ASSUME_NONNULL_BEGIN

@interface FilesWindowController : NSWindowController

@property (readonly)    Team    *team;

+ (instancetype)windowControllerForTeam:(Team *)team;

@end

NS_ASSUME_NONNULL_END

extern NSString * const FilesWindowWillCloseNotification;