//
//  ModelListProcessor.h
//  Slack Files
//
//  Created by Chris DeSalvo on 6/23/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface ModelListProcessor : NSObject

- (instancetype)initWithTeamId:(NSString *)teamId;

- (void)processServerChannelList:(NSArray <NSDictionary *> *)channels;
- (void)processServerFileList:(NSArray <NSDictionary *> *)files;
- (void)processServerGroupList:(NSArray <NSDictionary *> *)channels;
- (void)processServerIMList:(NSArray <NSDictionary *> *)channels;
- (void)processServerUserList:(NSArray <NSDictionary *> *)users;

@end

NS_ASSUME_NONNULL_END
