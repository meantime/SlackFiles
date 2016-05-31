//
//  SlackAuth.h
//  Slack Files
//
//  Created by Chris DeSalvo on 5/30/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

@import Foundation;

@interface SlackAuth : NSObject

@property (readonly, copy, nonnull) NSString    *uniqueId;

- (void)run;
- (void)processResponse:(nonnull NSURL *)response;

@end
