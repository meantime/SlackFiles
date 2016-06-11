//
//  File.h
//  Slack Files
//
//  Created by Chris DeSalvo on 6/4/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

#import "SlackModelObject.h"
#import "User.h"

@interface File : SlackModelObject

@property   NSString            *fileId;
@property   User                *creator;
@property   NSString            *filename;
@property   NSString            *title;
@property   NSString            *mimeType;
@property   NSString            *prettyType;
@property   NSDate              *created;
@property   NSDate              *timestamp;
@property   NSNumber<RLMInt>    *filesize;
@property   NSString            *thumbnailURL;

+ (void)fixBadTimestamps;

+ (NSDate *)oldestTimestampForTeam:(Team *)team;
+ (NSDate *)oldesetTimestampInGapForTeam:(Team *)team;
+ (NSDate *)newestTimestampForTeam:(Team *)team;

- (NSImage *)filesystemIcon;

@end

RLM_ARRAY_TYPE(File)
