//
//  File.m
//  Slack Files
//
//  Created by Chris DeSalvo on 6/4/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

#import "File.h"

@import Cocoa;

#import "Team.h"

static NSCache  *gMIMETypeIconCache;
static NSCache  *gExtensionIconCache;

@implementation File

+ (void)initialize
{
    gMIMETypeIconCache = [NSCache new];
    gExtensionIconCache = [NSCache new];
}

+ (NSDictionary *)valuesFromNetworkResponse:(NSDictionary *)response
{
    NSMutableDictionary *values = [NSMutableDictionary dictionary];

    values[@"fileId"] = response[@"id"];
    values[@"filename"] = response[@"name"];
    values[@"title"] = response[@"title"];
    values[@"mimeType"] = response[@"mimetype"];
    values[@"prettyType"] = response[@"pretty_type"];
    values[@"creatorUserId"] = response[@"user"];

    NSUInteger  number = [response[@"created"] unsignedIntegerValue];

    values[@"creationDate"] = [NSDate dateWithTimeIntervalSince1970:number];

    number = [response[@"size"] unsignedIntegerValue];
    values[@"filesize"] = [NSNumber numberWithUnsignedInteger:number];

    values[@"jsonBlob"] = [NSJSONSerialization dataWithJSONObject:response options:0 error:nil];

    return [NSDictionary dictionaryWithDictionary:values];
}

+ (NSString *)primaryKey
{
    return @"fileId";
}

+ (NSDate *)oldestTimestampForTeam:(Team *)team
{
    RLMRealm    *realm = [RLMRealm defaultRealm];
    RLMResults  *files = [File objectsInRealm:realm where:@"team = %@", team];
    NSDate      *oldestTimestamp = [files minOfProperty:@"creationDate"];

    if (nil == oldestTimestamp)
    {
        oldestTimestamp = [NSDate date];
    }

    return oldestTimestamp;
}

+ (NSDate *)oldesetTimestampInGapForTeam:(Team *)team
{
    RLMRealm    *realm = [RLMRealm defaultRealm];
    RLMResults  *files = [File objectsInRealm:realm where:@"team = %@ AND creationDate > %@", team, team.syncBoundary];
    NSDate      *oldestTimestamp = [files minOfProperty:@"creationDate"];

    if (nil == oldestTimestamp)
    {
        oldestTimestamp = [NSDate date];
    }

    return oldestTimestamp;
}

+ (NSDate *)newestTimestampForTeam:(Team *)team
{
    RLMRealm    *realm = [RLMRealm defaultRealm];
    RLMResults  *files = [File objectsInRealm:realm where:@"team = %@", team];

    NSDate      *newestTimestamp = [files maxOfProperty:@"creationDate"];

    if (nil == newestTimestamp)
    {
        newestTimestamp = [NSDate dateWithTimeIntervalSince1970:0.0];
    }

    return newestTimestamp;
}

- (NSImage *)filesystemIcon
{
    NSImage     *iconImage = nil;

    //  The the file extension first
    NSString    *extension = [self.filename pathExtension];

    iconImage = [gExtensionIconCache objectForKey:extension];

    if (nil == iconImage)
    {
        iconImage = [[NSWorkspace sharedWorkspace] iconForFileType:extension];

        if (iconImage)
        {
            [gExtensionIconCache setObject:iconImage forKey:extension];
        }
    }

    if (nil == iconImage)
    {
        iconImage = [gMIMETypeIconCache objectForKey:self.mimeType];

        if (nil == iconImage)
        {
            //  Ok, let's try it by MIME type
            CFStringRef MIMEType = (__bridge CFStringRef) self.mimeType;
            CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, MIMEType, NULL);
            NSString    *UTIString = (__bridge_transfer NSString *) UTI;

            iconImage = [[NSWorkspace sharedWorkspace] iconForFileType:UTIString];

            if (iconImage)
            {
                [gMIMETypeIconCache setObject:iconImage forKey:self.mimeType];
            }
        }
    }

    if (nil == iconImage)
    {
        iconImage = [gExtensionIconCache objectForKey:(__bridge NSString *) kUTTypeItem];

        if (nil == iconImage)
        {
            //  Last resort, try to load a generic document icon
            iconImage = [[NSWorkspace sharedWorkspace] iconForFileType:(__bridge NSString *) kUTTypeItem];

            if (iconImage)
            {
                [gExtensionIconCache setObject:iconImage forKey:(__bridge NSString *) kUTTypeItem];
            }
        }
    }

    return iconImage;
}

@end
