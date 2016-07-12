//
//  SlackAPI.h
//  Slack Files
//
//  Created by Chris DeSalvo on 6/3/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

@import Cocoa;

@protocol SlackRealtimeMessageDelegate;

NS_ASSUME_NONNULL_BEGIN

typedef void (^APICompletionBlock)(NSDictionary * _Nullable result, NSError * _Nullable error);

extern const struct SlackEndpoints
{
    NSString    __unsafe_unretained *channelsList;
    NSString    __unsafe_unretained *filesInfo;
    NSString    __unsafe_unretained *filesList;
    NSString    __unsafe_unretained *filesShare;
    NSString    __unsafe_unretained *groupsInfo;
    NSString    __unsafe_unretained *groupsList;
    NSString    __unsafe_unretained *imList;
    NSString    __unsafe_unretained *mpimList;
    NSString    __unsafe_unretained *oauthAccess;
    NSString    __unsafe_unretained *rtmLeanStart;
    NSString    __unsafe_unretained *rtmStart;
    NSString    __unsafe_unretained *teamInfo;
    NSString    __unsafe_unretained *usersInfo;
    NSString    __unsafe_unretained *usersList;
} SlackEndpoints;

@class Team;

@interface SlackAPI : NSObject

@property (nonatomic, nullable, weak)   id<SlackRealtimeMessageDelegate>    realtimeMessageDelegate;

- (instancetype)initWithTeam:(nullable Team *)team NS_DESIGNATED_INITIALIZER;

- (NSURLRequest *)requestForEndpoint:(NSString *)endpoint arguments:(nullable NSDictionary *)args;
- (void)callEndpoint:(NSString *)endpoint withArguments:(nullable NSDictionary *)args completion:(APICompletionBlock)completion;

- (void)suspend;
- (void)resume;

- (void)openRealtimeSocket;
- (void)closeRealtimeSocket;

@end

NS_ASSUME_NONNULL_END
