//
//  User.h
//  Slack Files
//
//  Created by Chris DeSalvo on 6/11/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

@import Realm;

#import "Team.h"

NS_ASSUME_NONNULL_BEGIN

@interface User : RLMObject

@property NSString  *userId;
@property Team      *team;
@property NSString  *username;
@property NSString  *realName;
@property NSString  *title;
@property NSString  *profileImageURL;
@property NSData    *jsonBlob;

+ (NSDictionary *)valuesFromNetworkResponse:(NSDictionary *)response;
+ (NSString *)bestImageURLFromProfileInfo:(NSDictionary *)profile;

@end

NS_ASSUME_NONNULL_END