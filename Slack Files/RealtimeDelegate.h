//
//  RealtimeDelegate.h
//  Slack Files
//
//  Created by Chris DeSalvo on 6/21/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

@import SocketRocket;

NS_ASSUME_NONNULL_BEGIN

@interface RealtimeDelegate : NSObject <SRWebSocketDelegate>

- (instancetype)initWithTeamId:(NSString *)teamId;

@end

NS_ASSUME_NONNULL_END
