//
//  Team.h
//  Slack Files
//
//  Created by Chris DeSalvo on 6/3/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

@import Realm;

@interface Team : RLMObject

@property NSString  *apiToken;

@property NSString  *teamId;
@property NSString  *teamName;
@property NSString  *userId;
@property NSString  *userName;
@property NSDate    *syncBoundary;

- (void)updateWithAuthResponse:(NSDictionary *)response;
- (void)updateSyncBoundaryToDate:(NSDate *)date;

+ (NSString *)bestImageURLFromTeamInfo:(NSDictionary *)info;

@end
