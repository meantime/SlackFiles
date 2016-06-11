//
//  User.h
//  Slack Files
//
//  Created by Chris DeSalvo on 6/11/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

#import "SlackModelObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface User : SlackModelObject

@property NSString  *userId;
@property NSString  *username;
@property NSString  *realName;
@property NSString  *title;
@property NSString  *profileImageURL;

+ (NSString *)bestImageURLFromProfileInfo:(NSDictionary *)profile;

@end

NS_ASSUME_NONNULL_END