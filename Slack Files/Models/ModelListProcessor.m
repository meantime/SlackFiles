//
//  ModelListProcessor.m
//  Slack Files
//
//  Created by Chris DeSalvo on 6/23/16.
//  Copyright © 2016 Chris DeSalvo. All rights reserved.
//

#import "ModelListProcessor.h"

@import Realm;

#import "Channel.h"
#import "File.h"
#import "Group.h"
#import "IM.h"
#import "Team.h"
#import "User.h"

@interface ModelListProcessor ()

@property (nonatomic, copy)     NSString            *teamId;
@property (nonatomic, strong)   dispatch_queue_t    processingQueue;

@end

@implementation ModelListProcessor

- (instancetype)initWithTeamId:(NSString *)teamId
{
    self = [super init];
    
    if (self)
    {
        self.teamId = teamId;

        dispatch_queue_attr_t   attributes = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_DEFAULT, 0);
        NSString                *queueName = [NSString stringWithFormat:@"%@ list processing queue", self.teamId];
        
        self.processingQueue = dispatch_queue_create(queueName.UTF8String, attributes);
    }
    
    return self;
}

- (void)dealloc
{
    self.processingQueue = 0;
}

- (void)processServerFileList:(NSArray *)files
{
    NSLog(@"Processing %ld files", files.count);
    
    if (files.count < 1)
    {
        return;
    }

    dispatch_async(self.processingQueue, ^{
        
        RLMRealm    *realm = [RLMRealm defaultRealm];
        
        [realm transactionWithBlock:^{
            
            NSUInteger  newFileCount = 0;
            Team        *team = [Team objectInRealm:realm forPrimaryKey:self.teamId];
            
            for (NSDictionary *f in files)
            {
                File    *file = [File objectInRealm:realm forPrimaryKey:f[@"id"]];
                
                if (nil == file)
                {
                    newFileCount++;
                }
                
                NSDictionary    *values = [File valuesFromNetworkResponse:f];
                
                file = [File createOrUpdateInRealm:realm withValue:values];
                
                User    *creator = [User objectInRealm:realm forPrimaryKey:f[@"user"]];
                
                file.team = team;
                file.creator = creator;
            }
        }];
    });
}

- (void)processServerUserList:(NSArray *)users
{
    NSLog(@"Processing %ld users", users.count);
    
    if (users.count < 1)
    {
        return;
    }
    
    dispatch_async(self.processingQueue, ^{
        
        RLMRealm    *realm = [RLMRealm defaultRealm];
        Team        *team = [Team objectInRealm:realm forPrimaryKey:self.teamId];
        
        [realm transactionWithBlock:^{
            
            NSUInteger  newUserCount = 0;
            
            for (NSDictionary *u in users)
            {
                User    *user = [User objectInRealm:realm forPrimaryKey:u[@"id"]];
                
                if (nil == user)
                {
                    newUserCount++;
                }
                
                NSDictionary    *values = [User valuesFromNetworkResponse:u];
                
                user = [User createOrUpdateInRealm:realm withValue:values];
                user.team = team;
            }
            
            NSLog(@"New users added: %ld", newUserCount);
        }];
    });
}

- (void)processServerChannelList:(NSArray *)channels
{
    NSLog(@"Processing %ld channels", channels.count);
    
    if (channels.count < 1)
    {
        return;
    }
    
    dispatch_async(self.processingQueue, ^{
        
        RLMRealm    *realm = [RLMRealm defaultRealm];
        Team        *team = [Team objectInRealm:realm forPrimaryKey:self.teamId];
        
        [realm transactionWithBlock:^{
            
            NSUInteger  newChannelCount = 0;
            
            for (NSDictionary *c in channels)
            {
                Channel *channel = [Channel objectInRealm:realm forPrimaryKey:c[@"id"]];
                
                if (nil == channel)
                {
                    newChannelCount++;
                }
                
                NSDictionary    *values = [Channel valuesFromNetworkResponse:c];
                
                channel = [Channel createOrUpdateInRealm:realm withValue:values];
                channel.team = team;
            }
            
            NSLog(@"New channels added: %ld", newChannelCount);
        }];
    });
}

- (void)processServerGroupList:(NSArray *)channels
{
    NSLog(@"Processing %ld private channels", channels.count);
    
    if (channels.count < 1)
    {
        return;
    }
    
    dispatch_async(self.processingQueue, ^{
        
        RLMRealm    *realm = [RLMRealm defaultRealm];
        Team        *team = [Team objectInRealm:realm forPrimaryKey:self.teamId];
        
        [realm transactionWithBlock:^{
            
            NSUInteger  newChannelCount = 0;
            
            for (NSDictionary *c in channels)
            {
                Group   *channel = [Group objectInRealm:realm forPrimaryKey:c[@"id"]];
                
                if (nil == channel)
                {
                    newChannelCount++;
                }
                
                NSDictionary    *values = [Group valuesFromNetworkResponse:c];
                
                channel = [Group createOrUpdateInRealm:realm withValue:values];
                channel.team = team;
            }
            
            NSLog(@"New private channels added: %ld", newChannelCount);
        }];
    });
}

- (void)processServerIMList:(NSArray *)channels
{
    NSLog(@"Processing %ld direct message channels", channels.count);
    
    if (channels.count < 1)
    {
        return;
    }
    
    dispatch_async(self.processingQueue, ^{
        
        RLMRealm    *realm = [RLMRealm defaultRealm];
        Team        *team = [Team objectInRealm:realm forPrimaryKey:self.teamId];
        
        [realm transactionWithBlock:^{
            
            NSUInteger  newChannelCount = 0;
            
            for (NSDictionary *c in channels)
            {
                IM  *channel = [IM objectInRealm:realm forPrimaryKey:c[@"id"]];
                
                if (nil == channel)
                {
                    newChannelCount++;
                }
                
                NSDictionary    *values = [IM valuesFromNetworkResponse:c];
                
                channel = [IM createOrUpdateInRealm:realm withValue:values];
                channel.team = team;
            }
            
            NSLog(@"New direct message channels added: %ld", newChannelCount);
        }];
    });
}

@end
