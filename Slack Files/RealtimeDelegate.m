//
//  RealtimeDelegate.m
//  Slack Files
//
//  Created by Chris DeSalvo on 6/21/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

#import "RealtimeDelegate.h"

@import Realm;

#import "File.h"
#import "ModelListProcessor.h"
#import "SlackAPI.h"
#import "User.h"

@interface RealtimeDelegate ()

@property (nonatomic, strong)   dispatch_queue_t    messageProcessingQueue;
@property (nonatomic, strong)   NSString            *teamId;
@property (nonatomic, weak)     SlackAPI            *slackAPI;
@property (nonatomic, strong)   ModelListProcessor  *modelProcessor;

@end

@implementation RealtimeDelegate

- (instancetype)initWithTeamId:(NSString *)teamId
{
    self = [super init];

    if (self)
    {
        self.teamId = teamId;
        self.modelProcessor = [[ModelListProcessor alloc] initWithTeamId:teamId];
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

- (void)setAPI:(SlackAPI *)api
{
    self.slackAPI = api;
}

#pragma mark - <SRWebSocketDelegate>

- (BOOL)webSocketShouldConvertTextFrameToString:(SRWebSocket *)webSocket
{
    //  Have to do this to force everything to be piped through didReceiveMessageWithData
    return NO;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessageWithData:(NSData *)data
{
    dispatch_async(self.messageProcessingQueue, ^{

        NSDictionary    *message = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSString        *type = message[@"type"];

        if ([@"file_created" isEqualToString:type])
        {
            [self processCreateOrUpdateFileMessage:message[@"file"]];
        }
        else if ([@"file_change" isEqualToString:type])
        {
            [self processCreateOrUpdateFileMessage:message[@"file"]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [[NSNotificationCenter defaultCenter] postNotificationName:[File notificationKeyForFileWithId:message[@"file"][@"id"]]
                                                                    object:nil];
            });
        }
        else if ([@"file_shared" isEqualToString:type])
        {
            [self processCreateOrUpdateFileMessage:message[@"file"]];
        }
        else if ([@"file_unshared" isEqualToString:type])
        {
            [self processCreateOrUpdateFileMessage:message[@"file"]];
        }
        else if ([@"file_deleted" isEqualToString:type])
        {
            [self processDeleteFileMessage:message[@"file_id"]];
        }
        else if ([@"presence_change" isEqualToString:type])
        {
//            User    *user = [User objectForPrimaryKey:message[@"user"]];
//            
//            NSLog(@"presence_change: %@:%@", user.realName, message[@"presence"]);
        }
        else
        {
//            NSLog(@"Ignoring message of type: %@", type);
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

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongData
{
    NSDictionary    *pong = [NSJSONSerialization JSONObjectWithData:pongData options:0 error:nil];

    NSLog(@"webSocket didReceivePong: %@", pong);
}

#pragma mark - File Message Processing

- (void)processCreateOrUpdateFileMessage:(NSDictionary *)file
{
    NSString    *fileId = file[@"id"];
    
    [self.slackAPI callEndpoint:SlackEndpoints.filesInfo withArguments:@{ @"file" : fileId } completion:^(NSDictionary * _Nullable result, NSError * _Nullable error) {
        
        if ([result[@"ok"] boolValue])
        {
            [self.modelProcessor processServerFileList:@[ result[@"file"] ]];
        }
    }];
}

- (void)processDeleteFileMessage:(NSString *)fileId
{
    RLMRealm    *realm = [RLMRealm defaultRealm];
    File        *file = [File objectInRealm:realm forPrimaryKey:fileId];
    
    if (file)
    {
        [realm transactionWithBlock:^{
            
            [realm deleteObject:file];
        }];
    }
}

@end
