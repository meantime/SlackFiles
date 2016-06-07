//
//  WindowController.h
//  Slack Files
//
//  Created by Chris DeSalvo on 6/6/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

@import Cocoa;

@class File;

NS_ASSUME_NONNULL_BEGIN

@interface WindowController : NSWindowController

@property (nonnull, readonly)   File    *file;

+ (instancetype)windowControllerForFile:(File *)file;

- (void)loadContentWithCompletion:(void (^)(NSData * __nullable data, NSURLResponse * __nullable response, NSError * __nullable error))completionHandler;

@end

NS_ASSUME_NONNULL_END
