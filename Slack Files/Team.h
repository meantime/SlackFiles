//
//  Team.h
//  Slack Files
//
//  Created by Chris DeSalvo on 6/3/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

@import Foundation;
@import Realm;

@interface Team : RLMObject

@property NSString    *apiToken;

@property NSString    *teamId;
@property NSString    *teamName;
@property NSString    *userId;
@property NSString    *userName;

@property NSDate      *lastSyncDate;

- (instancetype)initWithAuthResponse:(NSDictionary *)response;
- (void)updateWithAuthResponse:(NSDictionary *)response;

- (void)updateLastSyncDate;

@end
