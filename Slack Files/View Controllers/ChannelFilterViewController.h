//
//  ChannelFilterViewController.h
//  Slack Files
//
//  Created by Chris DeSalvo on 6/11/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

@import Cocoa;

@class Channel, Group, IM, Team, User;
@protocol ChannelFilterDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface ChannelFilterViewController : NSViewController

@property (weak)    id<ChannelFilterDelegate>   filterDelegate;

+ (instancetype)viewControllerForTeam:(Team *)team;

@end

@protocol ChannelFilterDelegate <NSObject>

- (void)clearFilter;
- (void)setMediaTypeFilter:(NSString *)filter;
- (void)filterWithChannel:(Channel *)channel;
- (void)filterWithGroup:(Group *)group;
- (void)filterWithIM:(IM *)im;
- (void)filterWithUser:(User *)user;

@end

NS_ASSUME_NONNULL_END
