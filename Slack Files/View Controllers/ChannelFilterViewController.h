//
//  ChannelFilterViewController.h
//  Slack Files
//
//  Created by Chris DeSalvo on 6/11/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

@import Cocoa;

@class Team;

NS_ASSUME_NONNULL_BEGIN

@interface ChannelFilterViewController : NSViewController

+ (instancetype)viewControllerForTeam:(Team *)team;

@end

NS_ASSUME_NONNULL_END
