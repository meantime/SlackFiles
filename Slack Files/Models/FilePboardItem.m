//
//  FilePboardItem.m
//  Slack Files
//
//  Created by Chris DeSalvo on 6/25/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

#import "FilePboardItem.h"

NSString * const SlackFilePBoardType = @"org.desalvo.SlackFiles.SlackFilePBoardType";

@implementation FilePboardItem

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];

    if (self)
    {
        self.teamId = [aDecoder decodeObjectForKey:@"teamId"];
        self.fileId = [aDecoder decodeObjectForKey:@"fileId"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.teamId forKey:@"teamId"];
    [aCoder encodeObject:self.fileId forKey:@"fileId"];
}

+ (NSPasteboardReadingOptions)readingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pboard
{
    if ([type isEqualToString:SlackFilePBoardType])
    {
        return NSPasteboardReadingAsKeyedArchive;
    }

    return 0;
}

+ (NSArray<NSString *> *)readableTypesForPasteboard:(NSPasteboard *)pasteboard
{
    return @[ SlackFilePBoardType ];
}

- (NSArray<NSString *> *)writableTypesForPasteboard:(NSPasteboard *)pasteboard
{
    return @[ SlackFilePBoardType ];
}

- (id)pasteboardPropertyListForType:(NSString *)type
{
    if ([type isEqualToString:SlackFilePBoardType])
    {
        return [NSKeyedArchiver archivedDataWithRootObject:self];
    }

    return nil;
}

@end
