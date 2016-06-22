//
//  RealtimeDelegate.m
//  Slack Files
//
//  Created by Chris DeSalvo on 6/21/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

#import "RealtimeDelegate.h"

@import Realm;

@interface RealtimeDelegate ()

@property   dispatch_queue_t    messageProcessingQueue;
@property   NSString            *teamId;

@end

@implementation RealtimeDelegate

- (instancetype)initWithTeamId:(NSString *)teamId
{
    self = [super init];

    if (self)
    {
        self.teamId = teamId;
    }

    return self;
}

- (void)dealloc
{
    [self closeProcessingQueue];
}

- (void)closeProcessingQueue
{
    self.messageProcessingQueue = 0;
}

#pragma mark - <SRWebSocketDelegate>

- (BOOL)webSocketShouldConvertTextFrameToString:(SRWebSocket *)webSocket
{
    //  Have to do this to force everything to be piped thruogh didReceiveMessageWithData
    return NO;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessageWithData:(NSData *)data
{
    dispatch_async(self.messageProcessingQueue, ^{

        NSDictionary    *message = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSString        *type = message[@"type"];

        if ([@"file_created" isEqualToString:type])
        {
            [self processCreateFileMessage:message[@"file"]];
        }
        else if ([@"file_shared" isEqualToString:type])
        {
            [self processShareFileMessage:message[@"file"]];
        }
        else if ([@"file_unshared" isEqualToString:type])
        {
            [self processUnshareFileMessage:message[@"file"]];
        }
        else if ([@"file_change" isEqualToString:type])
        {
            [self processChangeFileMessage:message[@"file"]];
        }
        else if ([@"file_deleted" isEqualToString:type])
        {
            [self processDeleteFileMessage:message[@"file_id"]];
        }
        else
        {
            NSLog(@"Ignoring message of type: %@", type);
        }
    });
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    NSLog(@"webSocketDidOpen for team %@", self.teamId);

    dispatch_queue_attr_t   attributes = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, 0);
    NSString                *queueName = [NSString stringWithFormat:@"%@ realtime queue", self.teamId];

    self.messageProcessingQueue = dispatch_queue_create(queueName.UTF8String, attributes);
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    NSLog(@"webSocketDidFailWithError for team %@, %@", self.teamId, error);

    [self closeProcessingQueue];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(nullable NSString *)reason wasClean:(BOOL)wasClean
{
    NSLog(@"webSocketDidCloseWithCode for team %@, code %ld, reason %@, was clean %d", self.teamId, code, reason, wasClean);
    [self closeProcessingQueue];
}

#pragma mark - File Message Processing

- (void)processCreateFileMessage:(NSDictionary *)file
{
    NSLog(@"Received file create: %@", file);
}

- (void)processShareFileMessage:(NSDictionary *)file
{
    NSLog(@"Received file share: %@", file);
}

- (void)processUnshareFileMessage:(NSDictionary *)file
{
    NSLog(@"Received file unshare: %@", file);
}

- (void)processChangeFileMessage:(NSDictionary *)file
{
    NSLog(@"Received file change: %@", file);
}

- (void)processDeleteFileMessage:(NSString *)fileId
{
    NSLog(@"Received file deleted: %@", fileId);
}

@end
