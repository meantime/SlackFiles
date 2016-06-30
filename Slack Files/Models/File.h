//
//  File.h
//  Slack Files
//
//  Created by Chris DeSalvo on 6/4/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

#import "SlackModelObject.h"

#import "Channel.h"
#import "Group.h"
#import "IM.h"
#import "User.h"

@interface File : SlackModelObject

@property   NSString            *fileId;                //  F12345
@property   User                *creator;
@property   NSString            *filename;              //  The actual filesystem filename
@property   NSString            *title;                 //  The title user the gave then they uploaded
@property   NSString            *type;                  //  Generic Slack type (e.g. images, gdocs, zips)
@property   NSString            *mimeType;
@property   NSString            *prettyType;            //  Display-ready name (e.g. GDoc Spreadsheet)
@property   NSDate              *created;               //  Date the file was created
@property   NSDate              *timestamp;             //  Date the file was last modified (for editable types)
@property   NSNumber<RLMInt>    *filesize;              //  In bytes
@property   NSString            *thumbnailURL;

@property   RLMArray<Channel *><Channel>    *channels;  //  Places where this file has been shared
@property   RLMArray<Group *><Group>        *groups;
@property   RLMArray<IM *><IM>              *ims;

+ (NSString *)notificationKeyForFileWithId:(NSString *)fileId;

//  Some files have a 'timestamp' field of zero. This corrects them to mirror the 'created' date
+ (void)fixBadTimestamps;

+ (NSDate *)oldestTimestampForTeam:(Team *)team;
+ (NSDate *)oldesetTimestampInGapForTeam:(Team *)team;
+ (NSDate *)newestTimestampForTeam:(Team *)team;

- (NSImage *)filesystemIcon;

@end

RLM_ARRAY_TYPE(File)
