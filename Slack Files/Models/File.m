//
//  File.m
//  Slack Files
//
//  Created by Chris DeSalvo on 6/4/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

#import "File.h"

@import Cocoa;

static NSCache  *gMIMETypeIconCache;
static NSCache  *gExtensionIconCache;

@implementation File

+ (void)initialize
{
    gMIMETypeIconCache = [NSCache new];
    gExtensionIconCache = [NSCache new];
}

+ (NSString *)primaryKey
{
    return @"fileId";
}

+ (NSDictionary *)valuesFromNetworkResponse:(NSDictionary *)response
{
    NSDictionary        *base = [[self superclass] valuesFromNetworkResponse:response];
    NSMutableDictionary *values = [NSMutableDictionary dictionary];

    [values addEntriesFromDictionary:base];

    values[@"fileId"] = response[@"id"];
    values[@"filename"] = response[@"name"];
    values[@"title"] = response[@"title"];
    values[@"mimeType"] = response[@"mimetype"];
    values[@"prettyType"] = response[@"pretty_type"];
    values[@"creatorUserId"] = response[@"user"];

    values[@"created"] = [File dateFromResponse:response withKey:@"created"];
    values[@"timestamp"] = [File dateFromResponse:response withKey:@"timestamp"];

    NSUInteger  number;

    number = [response[@"size"] unsignedIntegerValue];
    values[@"filesize"] = [NSNumber numberWithUnsignedInteger:number];

    values[@"thumbnailURL"] = [File bestThumbnailImageURLFromFileInfo:response];

    return [NSDictionary dictionaryWithDictionary:values];
}

+ (NSDate *)dateFromResponse:(NSDictionary *)response withKey:(NSString *)key
{
    NSUInteger  number = [response[key] unsignedIntegerValue];

    return [NSDate dateWithTimeIntervalSince1970:number];
}

+ (NSString *)bestThumbnailImageURLFromFileInfo:(NSDictionary *)info
{
#define TryIconNamed(x) { if (IsStringWithContents(info[(x)])) return info[(x)]; }

    TryIconNamed(@"thumb_160");
    TryIconNamed(@"thumb_80");
    TryIconNamed(@"thumb_64");
    TryIconNamed(@"thumb_360");
    TryIconNamed(@"thumb_480");
    TryIconNamed(@"thumb_720");
    TryIconNamed(@"thumb_960");
    TryIconNamed(@"thumb_1024");

#undef TryIconNamed

    return @"";
}

+ (void)fixBadTimestamps
{
    NSCalendar          *calendar = [NSCalendar currentCalendar];
    NSDate              *testDate = [calendar dateWithEra:1 year:2000 month:1 day:1 hour:1 minute:1 second:1 nanosecond:1];

    RLMRealm    *realm = [RLMRealm defaultRealm];
    RLMResults  *files = [File objectsInRealm:realm where:@"timestamp < %@", testDate];

    [realm transactionWithBlock:^{

        for (File *file in files)
        {
            file.timestamp = file.created;
        }
    }];
}

+ (NSDate *)oldestTimestampForTeam:(Team *)team
{
    RLMRealm    *realm = [RLMRealm defaultRealm];

    RLMResults  *files = [File objectsInRealm:realm where:@"team = %@", team];
    NSDate      *oldestTimestamp = [files minOfProperty:@"timestamp"];

    if (nil == oldestTimestamp)
    {
        oldestTimestamp = [NSDate date];
    }

    return oldestTimestamp;
}

+ (NSDate *)oldesetTimestampInGapForTeam:(Team *)team
{
    RLMRealm    *realm = [RLMRealm defaultRealm];
    RLMResults  *files = [File objectsInRealm:realm where:@"team = %@ AND timestamp > %@", team, team.syncBoundary];
    NSDate      *oldestTimestamp = [files minOfProperty:@"timestamp"];

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

    NSDate      *newestTimestamp = [files maxOfProperty:@"timestamp"];

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
