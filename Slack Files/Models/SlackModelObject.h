//
//  SlackModelObject.h
//  Slack Files
//
//  Created by Chris DeSalvo on 6/11/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

@import Realm;

#import "Team.h"

@interface SlackModelObject : RLMObject

@property   Team    *team;
@property   NSData  *jsonBlob;

+ (NSDictionary *)valuesFromNetworkResponse:(NSDictionary *)response;

@end
