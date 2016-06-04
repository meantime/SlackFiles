//
//  KeychainAccess.h
//  Slack Files
//
//  Created by Chris DeSalvo on 6/4/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

@import Foundation;

@interface KeychainAccess : NSObject

+ (OSStatus)writeData:(NSData *)data withServiceName:(NSString *)serviceName error:(out NSError **)error;
+ (NSData *)readDataWithServiceName:(NSString *)serviceName error:(out NSError **)error;
+ (OSStatus)removeItemWithServiceName:(NSString *)serviceName error:(out NSError **)error;

@end