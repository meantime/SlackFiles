//
//  IM.h
//  Slack Files
//
//  Created by Chris DeSalvo on 6/11/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

#import "SlackModelObject.h"

#import "User.h"

NS_ASSUME_NONNULL_BEGIN

@interface IM : SlackModelObject

@property                       NSString            *imId;
@property                       NSString            *name;
@property                       User                *user;
@property (getter=isDeleted)    NSNumber<RLMBool>   *deleted;

@end

NS_ASSUME_NONNULL_END
