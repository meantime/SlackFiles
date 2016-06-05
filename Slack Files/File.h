//
//  File.h
//  Slack Files
//
//  Created by Chris DeSalvo on 6/4/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

@import Realm;

@class Team;

@interface File : RLMObject

@property   NSString            *fileId;
@property   Team                *team;
@property   NSString            *filename;
@property   NSString            *title;
@property   NSString            *mimeType;
@property   NSString            *prettyType;
@property   NSDate              *creationDate;
@property   NSNumber<RLMInt>    *filesize;
@property   NSString            *creatorUserId;
@property   NSData              *jsonBlob;

+ (NSDictionary *)valuesFromNetworkResponse:(NSDictionary *)response;

+ (NSDate *)oldestTimestampForTeam:(Team *)team;
+ (NSDate *)oldesetTimestampInGapForTeam:(Team *)team;
+ (NSDate *)newestTimestampForTeam:(Team *)team;

@end

RLM_ARRAY_TYPE(File)
