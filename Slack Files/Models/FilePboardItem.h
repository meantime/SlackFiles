//
//  FilePboardItem.h
//  Slack Files
//
//  Created by Chris DeSalvo on 6/25/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const SlackFilePBoardType;

@interface FilePboardItem : NSObject<NSCoding, NSPasteboardReading, NSPasteboardWriting>

@property (copy)    NSString    *teamId;
@property (copy)    NSString    *fileId;

@end

NS_ASSUME_NONNULL_END
