//
//  AuthWindowController.h
//  Slack Files
//
//  Created by Chris DeSalvo on 6/1/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol AuthWindowDelegate;

@interface AuthWindowController : NSWindowController

@property (nullable, weak)  id<AuthWindowDelegate>  delegate;

+ (nullable instancetype)authWindowController;

- (void)startAuthSessionWithRequest:(nonnull NSURLRequest *)request;
- (void)startAccessSessionWithRequest:(nonnull NSURLRequest *)request;
- (void)finishSession;

@end

@protocol AuthWindowDelegate <NSObject>

@optional

- (void)authWindow:(nonnull AuthWindowController *)windowController didReceiveURLResponse:(nonnull NSURL *)url;
- (void)authWindow:(nonnull AuthWindowController *)windowController didReceiveJSONResponse:(nonnull NSString *)jsonString;
- (void)authWindow:(nonnull AuthWindowController *)windowController didReceiveTextResponse:(nonnull NSString *)text;
- (void)authWindow:(nonnull AuthWindowController *)windowController didReceiveErrorResponse:(nonnull NSError *)error;
- (void)authWindowCanceledByUser:(nonnull AuthWindowController *)windowController;

@end
