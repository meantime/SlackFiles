//
//  PDFWindowController.h
//  Slack Files
//
//  Created by Chris DeSalvo on 6/6/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

@import Cocoa;

@class File;

@interface PDFWindowController : NSWindowController

+ (instancetype)windowControllerForFile:(File *)file;

@end
