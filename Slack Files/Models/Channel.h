//
//  Channel.h
//  Slack Files
//
//  Created by Chris DeSalvo on 6/11/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

#import "SlackModelObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface Channel : SlackModelObject

@property                       NSString            *channelId;
@property                       NSString            *name;
@property (getter=isArchived)   NSNumber<RLMBool>   *archived;

@end

NS_ASSUME_NONNULL_END
